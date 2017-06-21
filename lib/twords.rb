# frozen_string_literal: true

require 'date'
require 'twitter'

require 'twords/version'

# Twords.config do |config|
#   config.throw_aways = %w[the for and a i of if]
#   config.max_age     = 14
#   config.up_to { Time.now }
#
#   config.twitter_client do |twitter|
#     twitter.consumer_key        = YOUR_TWITTER_CONSUMER_KEY
#     twitter.consumer_secret     = YOUR_TWITTER_CONSUMER_SECRET
#     twitter.access_token        = YOUR_TWITTER_ACCESS_TOKEN
#     twitter.access_token_secret = YOUR_TWITTER_ACCESS_TOKEN_SECRET
#   end
# end
#
# twords = Twords.new 'user_one', 'user_two'
#
# twords.audit
# # => true
#
# twords.words
# # => { "butts"=>35, "poo"=>32, "pups"=>28, ... }
class Twords
  class << self
    attr_reader :throw_aways, :range, :client, :up_to_block

    def config(&block)
      class_eval(&block)
    end

    def twitter_client(&block)
      @client = Twitter::REST::Client.new(&block)
    end

    def throw_aways=(*args)
      @throw_aways = args.flatten
    end

    def range=(integer)
      @range = integer
    end

    def up_to(&time_block)
      raise ArgumentError, 'object must respond to #call' unless time_block.respond_to?(:call)
      @up_to_block = time_block
    end
  end

  attr_reader :screen_names, :words, :requests, :client

  def initialize(*screen_names)
    @screen_names = screen_names
    @words        = {}
    @requests     = 0
  end

  def client
    @_client ||= self.class.client
  end

  def range
    @_range ||= self.class.range
  end

  def audited?
    @audited
  end

  def sort_words
    words.sort { |a, b| b.last <=> a.last }
  end

  def timeline
    @_timeline ||= screen_names.map { |name| fetch_timeline(name) }.flatten
  end

  # Make two cursored API calls to fetch the 400 most recent tweets
  def fetch_timeline(screen_name)
    return [] if screen_name.to_s.empty?
    @requests += 1
    timeline = client.user_timeline(screen_name, count: 200)
    return timeline if timeline.empty?
    fetch_older_tweets(timeline, screen_name)
  end

  def fetch_older_tweets(timeline, screen_name)
    return timeline if age_of_tweet_in_days(timeline.last) > range
    @requests += 1
    timeline += client.user_timeline(
        screen_name,
        max_id: timeline.last.id - 1,
        count: 200
    )
    fetch_older_tweets(timeline, screen_name)
  end

  def recent_tweets
    @_recent_tweets ||= timeline.each_with_object([]) do |tweet, memo|
      memo << tweet if age_of_tweet_in_days(tweet) <= range
    end.sort { |a, b| b.created_at <=> a.created_at }
  end

  def age_of_tweet_in_days(tweet)
    (self.class.up_to_block.call - tweet.created_at) / 60 / 60 / 24
  end

  def count_words
    recent_tweets.each do |tweet|
      tweet_with_full_text = fetch_tweet_with_full_text(tweet)
      words_array = tweet_with_full_text.attrs[:full_text].downcase.split(' ')
      words_array.each do |word|
        next if self.class.throw_aways.include?(word)
        if words.has_key?(word)
          words[word] += 1
        else
          words[word] = 1
        end
      end
    end
  end

  def fetch_tweet_with_full_text(tweet)
    @requests += 1
    client.status(tweet.id, tweet_mode: 'extended')
  end

  def audit
    count_words unless audited?
    @audited = true
  end

  def recent_tweets_count
    @_recent_tweets_count ||= recent_tweets.count
  end
end
