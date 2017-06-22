# frozen_string_literal: true

require 'csv'
require 'twitter'
require 'uri'

require 'twords/version'

# Twords.config do |config|
#   config.rejects = %w[the for and a i of if]
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
    attr_reader :rejects, :client, :up_to_block, :include_hashtags, :include_uris,
                :include_mentions
    attr_accessor :range

    def config
      yield self
    end

    def twitter_client(&block)
      @client = Twitter::REST::Client.new(&block)
    end

    def rejects=(*args)
      @rejects = args.flatten
    end

    def include_hashtags=(boolean)
      not_a_boolean_error(boolean)
      @include_hashtags = boolean
    end

    def include_uris=(boolean)
      not_a_boolean_error(boolean)
      @include_uris = boolean
    end
    alias include_urls include_uris

    def include_mentions=(boolean)
      not_a_boolean_error(boolean)
      @include_mentions = boolean
    end

    def not_a_boolean_error(boolean)
      raise ArgumentError, 'argument must be a booolean value' unless a_boolean?(boolean)
    end

    def a_boolean?(other)
      [true, false].include?(other)
    end

    def up_to(&time_block)
      @up_to_block = time_block
    end
  end

  attr_reader :screen_names, :words, :requests, :client

  def initialize(*screen_names)
    @screen_names = screen_names.flatten
    @words        = {}
    @requests     = 0
  end

  def client
    @_client ||= self.class.client
  end

  def range
    @_range ||= self.class.range
  end

  def rejects
    @_rejects ||= self.class.rejects
  end

  def audited?
    @audited
  end

  def hashtag?(word)
    return false if self.class.include_hashtags
    !(word =~ /#(\w+)/).nil?
  end

  def uri?(word)
    return false if self.class.include_uris
    !(word =~ URI.regexp).nil?
  end

  def mention?(word)
    return false if self.class.include_mentions
    !(word =~ /@(\w+)/).nil?
  end

  def hashtags
    /#/
  end

  def should_be_skipped?(word)
    rejects.include?(word) || hashtag?(word) || uri?(word) || mention?(word)
  end

  def sort_words
    words.sort { |a, b| b.last <=> a.last }
  end
  alias words_forward sort_words

  def timeline
    @_timeline ||= screen_names.map { |name| fetch_timeline(name) }.flatten
  end

  # Make two cursored API calls to fetch the 400 most recent tweets
  def fetch_timeline(screen_name)
    return [] if screen_name.to_s.empty?
    @requests += 1
    timeline = client.user_timeline(screen_name, tweet_mode: 'extended', count: 200)
    return timeline if timeline.empty?
    timeline = fetch_older_tweets(timeline, screen_name)
    puts "Fetched #{screen_name}'s timeline"
    timeline
  end

  def fetch_older_tweets(timeline, screen_name)
    return timeline if age_of_tweet_in_days(timeline.last) > range
    @requests += 1
    timeline += client.user_timeline(
      screen_name,
      tweet_mode: 'extended',
      max_id: timeline.last.id - 1,
      count: 200
    )
    fetch_older_tweets(timeline, screen_name)
  end

  def tweets
    @_tweets ||= timeline.each_with_object([]) do |tweet, memo|
      memo << tweet if age_of_tweet_in_days(tweet) <= range
    end
  end

  def sort_tweets
    tweets.sort { |a, b| b.created_at <=> a.created_at }
  end

  def sort_tweets!
    tweets.sort! { |a, b| b.created_at <=> a.created_at }
  end

  def age_of_tweet_in_days(tweet)
    (self.class.up_to_block.call.to_time - tweet.created_at) / 86_400
  end

  def count_words
    words.clear
    tweets.each do |tweet|
      words_array = tweet.attrs[:full_text].downcase.split(' ')
      words_array.each do |word|
        next if should_be_skipped?(word)
        if words.key?(word)
          words[word] += 1
        else
          words[word] = 1
        end
      end
    end
  end

  def audit
    count_words unless audited?
    @audited = true
  end

  def audit!
    @audited = false
    audit
  end

  def tweets_count
    @_tweets_count ||= tweets.count
  end

  def to_csv
    CSV.generate do |csv|
      csv << %w[word count]
      sort_words.each do |word_count|
        csv << word_count
      end
    end
  end

  def write_to_csv(opts = {})
    filename = opts.fetch(:filename) { 'twords_report.csv' }
    write_file(filename, :to_csv, opts)
  end

  def to_json
    sort_words.to_h.to_json
  end

  def write_to_json(opts = {})
    filename = opts.fetch(:filename) { 'twords_report.json' }
    write_file(filename, :to_json, opts)
  end

  def write_file(filename, method, opts = {})
    File.open(filename, 'w', opts) { |file| file.write send(method) }
  end
end
