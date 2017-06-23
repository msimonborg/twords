# frozen_string_literal: true

require 'csv'
require 'uri'

require 'twords/config_accessible'
require 'twords/word_matcher'

# Instance methods
class Twords
  include ConfigAccessible

  # The screen names included in the analysis
  #
  # @api public
  # @return [Array<String>] if names are provided to #initialize
  # @return [Array] if no names are provided to #initialize
  attr_reader :screen_names

  # The words and their number of occurrences
  #
  # @api public
  # @return [Hash] returns the word(String) and counts(Integer) as key-value pairs
  attr_reader :words

  # Initializes a new Twords object
  #
  # @api public
  # @param screen_names [Array<String>] any number of screen names to include in the analysis
  # @return [Twords]
  def initialize(*screen_names)
    @screen_names = screen_names.flatten
    @words        = {}
    @audited      = false
  end

  # Have the #screen_names already been audited?
  #
  # @api public
  # @return [true] if already audited
  # @return [false] if not audited yet
  def audited?
    @audited
  end

  # Fetch tweets and count words. Short circuits and returns true if already audited.
  #
  # @api public
  # @return [true]
  def audit
    count_words unless audited?
    @audited = true
  end

  # Clear all results and audit from scratch
  #
  # @api public
  # @return [true] always returns true unless an error is raised
  def audit!
    instance_variables.reject { |ivar| %i[@screen_names @words].include?(ivar) }.each do |ivar|
      instance_variable_set(ivar, nil)
    end

    @audited = false

    audit
  end

  # Sort words by frequency in descending order
  #
  # @api public
  # @return [Array<Array<String, Integer>>]
  def sort_words
    @_sort_words ||= words.sort { |a, b| b.last <=> a.last }
  end
  alias words_forward sort_words

  # Returns all of the tweets that fall within the configured time range
  #
  # @api public
  # @return [Array<Twitter::Tweet>]
  def tweets
    @_tweets ||= client.filter_tweets(screen_names)
  end

  # Returns an array of #tweets sorted by time created in descending order
  #
  # @api public
  # @return [Array<Twitter::Tweet>]
  def sort_tweets
    tweets.sort { |a, b| b.created_at <=> a.created_at }
  end

  # #sort_tweets destructively
  #
  # @api public
  # @return [Array<Twitter::Tweet>]
  def sort_tweets!
    tweets.sort! { |a, b| b.created_at <=> a.created_at }
  end

  # Number of tweets being analyzed
  #
  # @api public
  # @return [Integer]
  def tweets_count
    @_tweets_count ||= tweets.count
  end

  # Total occurrences of all words included in analysis, i.e. sum of the count of all words.
  #
  # @api public
  # @return [Integer]
  def total_word_count
    @_total_word_count ||= words.values.reduce(:+)
  end

  # The frequency of each word as a share of the #total_word_count
  #
  # @api public
  # @return [Hash] returns the word(String) and percentage(Float) as key-value pairs
  def percentages
    @_percentages ||= words.each_with_object({}) do |word_count, hash|
      hash[word_count.first] = percentage(word_count.last)
    end
  end

  # Sorts #percentages in descending order
  #
  # @api public
  # @return [Array<Array<String, Float>>]
  def sort_percentages
    @_sort_percentages ||= percentages.sort { |a, b| b.last <=> a.last }
  end

  # Generate a CSV formatted String of the sorted results, with column headers "word, count"
  #
  # @api public
  # @return [String] in CSV format
  def to_csv
    CSV.generate do |csv|
      csv << %w[word count]
      sort_words.each do |word_count|
        csv << word_count
      end
    end
  end

  # Write the output of #to_csv to a file.
  #
  # @api public
  # @return [Integer] representing the byte count of the file
  # @param opts [Hash] File writing options. All except for :filename are passed to File#open.
  # @option opts [String] :filename A relative pathname. Defaults to 'twords_report.csv'
  def write_to_csv(opts = {})
    filename = opts.fetch(:filename) { 'twords_report.csv' }
    write_file(filename, :to_csv, opts)
  end

  # Generate a JSON formatted String of the sorted results, as one hash object with word-count
  # key-value pairs.
  #
  # @api public
  # @return [String] in JSON format
  def to_json
    sort_words.to_h.to_json
  end

  # Write the output of #to_json to a file.
  #
  # @api public
  # @return [Integer] representing the byte count of the file
  # @param opts [Hash] customizable file writing options. All but :filename arepassed to File#open
  # @option opts [String] :filename A relative pathname. Defaults to 'twords_report.json'
  def write_to_json(opts = {})
    filename = opts.fetch(:filename) { 'twords_report.json' }
    write_file(filename, :to_json, opts)
  end

  private

  # @api private
  def client
    config.client
  end

  # @api private
  def count_words
    words.clear
    tweets.each do |tweet|
      words_array(tweet).each do |word|
        next if WordMatcher.should_be_skipped?(word)
        words.key?(word) ? words[word] += 1 : words[word] = 1
      end
    end
  end

  # @api private
  def words_array(tweet)
    tweet.attrs[:full_text].downcase.split(' ')
  end

  # @api private
  def percentage(count)
    (count / total_word_count.to_f * 100)
  end

  # @api private
  def write_file(filename, method, opts = {})
    File.open(filename, 'w', opts) { |file| file.write send(method) }
  end
end
