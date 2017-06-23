# frozen_string_literal

require 'twords/config_accessible'

class Twords
  # Twitter REST API client
  class TwitterClient
    include ConfigAccessible

    # A Twitter::REST::Client that provides an interface to the Twitter API
    #
    # @api public
    # @return [Twitter::REST::Client]
    attr_reader :client

    # Initializes a new Twords::TwitterClient object and assigns to the @client instance variable
    #
    #   Twords::TwitterClient.new do |twitter|
    #     twitter.consumer_key        = "YOUR_CONSUMER_KEY"
    #     twitter.consumer_secret     = "YOUR_CONSUMER_SECRET"
    #     twitter.access_token        = "YOUR_ACCESS_TOKEN"
    #     twitter.access_token_secret = "YOUR_ACCESS_SECRET"
    #   end
    #
    # @api public
    # for block { |twitter| ... }
    # @yield [Twitter::REST::Client] yields the Twitter::REST::Client for configuration
    # @see https://github.com/sferik/twitter#configuration
    def initialize(&block)
      @client = Twitter::REST::Client.new(&block)
    end

    # Fetches the timelines for an array of screen names and filters them
    # by the configured time range.
    #
    # @api public
    # @param screen_names [Array<String>] the twitter screen names from which to pull the tweets
    def filter_tweets(screen_names)
      full_timeline(screen_names).each_with_object([]) do |tweet, memo|
        next if tweet.created_at > up_to_time
        memo << tweet if age_of_tweet_in_days(tweet) <= range
      end
    end

    private

    # @api private
    def full_timeline(screen_names)
      screen_names.map { |screen_name| fetch_user_timeline(screen_name) }.flatten.uniq
    end

    # @api private
    def fetch_user_timeline(screen_name)
      return [] if screen_name.to_s.empty?
      user_timeline = client.user_timeline(screen_name, tweet_mode: 'extended', count: 200)
      return user_timeline if user_timeline.empty?
      user_timeline = fetch_older_tweets(user_timeline, screen_name)
      puts "Fetched #{screen_name}'s timeline"
      user_timeline
    rescue Twitter::Error::TooManyRequests
      puts 'Rate limit exceeded, waiting 5 minutes' && sleep(300)
      fetch_user_timeline(screen_name)
    end

    # @api private
    def age_of_tweet_in_days(tweet)
      (up_to_time - tweet.created_at) / 86_400
    end

    # @api private
    def up_to_time
      config.up_to_time
    end

    # @api private
    def range
      config.range
    end

    # @api private
    def fetch_older_tweets(user_timeline, screen_name)
      return user_timeline if age_of_tweet_in_days(user_timeline.last) > range
      first_count = user_timeline.count
      user_timeline += client.user_timeline(
        screen_name,
        tweet_mode: 'extended',
        max_id: user_timeline.last.id - 1,
        count: 200
      )
      return user_timeline if user_timeline.count == first_count
      fetch_older_tweets(user_timeline, screen_name)
    end
  end
end
