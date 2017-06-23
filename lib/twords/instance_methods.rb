# frozen_string_literal: true

require 'csv'
require 'uri'

require 'twords/config_accessible'
require 'twords/word_matcher'

# Instance methods
class Twords
  include ConfigAccessible

  attr_reader :screen_names, :words

  def initialize(*screen_names)
    @screen_names = screen_names.flatten
    @words        = {}
  end

  def audited?
    @audited
  end

  def audit
    count_words unless audited?
    @audited = true
  end

  def audit!
    instance_variables.reject { |ivar| %i[@screen_names @words].include?(ivar) }.each do |ivar|
      instance_variable_set(ivar, nil)
    end

    audit
  end

  def sort_words
    @_sort_words ||= words.sort { |a, b| b.last <=> a.last }
  end
  alias words_forward sort_words

  def tweets
    @_tweets ||= client.filter_tweets(screen_names)
  end

  def sort_tweets
    tweets.sort { |a, b| b.created_at <=> a.created_at }
  end

  def sort_tweets!
    tweets.sort! { |a, b| b.created_at <=> a.created_at }
  end

  def tweets_count
    @_tweets_count ||= tweets.count
  end

  def total_word_count
    @_total_word_count ||= words.values.reduce(:+)
  end

  def percentages
    @_percentages ||= words.each_with_object({}) do |word_count, hash|
      hash[word_count.first] = percentage(word_count.last)
    end
  end

  def sort_percentages
    @_sort_percentages ||= percentages.sort { |a, b| b.last <=> a.last }
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

  private

  # private method
  def client
    config.client
  end

  # private method
  def count_words
    words.clear
    tweets.each do |tweet|
      words_array(tweet).each do |word|
        next if WordMatcher.should_be_skipped?(word)
        words.key?(word) ? words[word] += 1 : words[word] = 1
      end
    end
  end

  # private method
  def words_array(tweet)
    tweet.attrs[:full_text].downcase.split(' ')
  end

  # private method
  def percentage(count)
    (count / total_word_count.to_f * 100)
  end

  # private method
  def write_file(filename, method, opts = {})
    File.open(filename, 'w', opts) { |file| file.write send(method) }
  end
end
