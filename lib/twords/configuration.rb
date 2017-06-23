# frozen_string_literal: true

require 'twitter'
require 'twords/twitter_client'

class Twords
  # Configuration object for the Twords namespace. One instance to rule them all.
  # All options can be changed with public setter methods. One Twords::Configuration instance
  # is shared across all objects in the Twords namespace. Changing the configuration will affect
  # all objects, even those that are already instantiated. To set app configuration, do not
  # initialize a Twords::Configuration object directly - nothing will happen.
  # Do it through Twords.config(&block).
  #
  # @see Twords.config
  # @example
  #   Twords.config do |config|
  #     config.rejects = %w[my us we an w/ because b/c or are this is from
  #                         be on the for to and at our of in rt a with &amp;
  #                         that it by as if was]
  #
  #     config.range   = 30
  #     config.up_to { Time.now }
  #     config.include_hashtags = false
  #     config.include_uris     = false
  #     config.include_mentions = false
  #
  #     config.twitter_client do |twitter|
  #       twitter.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
  #       twitter.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
  #       twitter.access_token        = ENV['TWITTER_ACCESS_TOKEN']
  #       twitter.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
  #     end
  #   end
  class Configuration
    # Default words to ignore. Strings must match exactly and are checked with
    # Array#include?
    DEFAULT_REJECTS = %w[
      my us we an w/ because
      b/c or are this is from
      be on the for to and at
      our of in rt a with &amp;
      that it by as if was
    ].freeze

    # Default configuration block to pass to Twords::TwitterClient.new.
    # Feel free to customize the variables in a configuration block of your own,
    # but never hard code the values. Or just make the values available at the default
    # locations.
    DEFAULT_TWITTER_CONFIG = lambda do |twitter|
      twitter.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
      twitter.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
      twitter.access_token        = ENV['TWITTER_ACCESS_TOKEN']
      twitter.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
    end

    # Full set of default options that will be passed to the Configuration object
    # on initialization and reset.
    DEFAULT_OPTIONS = {
      include_uris:     false,
      include_hashtags: false,
      include_mentions: false,
      range:            30,
      client:           TwitterClient.new(&DEFAULT_TWITTER_CONFIG),
      up_to_block:      -> { Time.now },
      rejects:          DEFAULT_REJECTS
    }.freeze

    attr_reader :rejects, :client, :up_to_block, :include_hashtags, :include_uris,
                :include_mentions

    attr_accessor :range

    # Initializes a new Twords::Configuration object with default configuration.
    #
    # @api public
    # @return [Twords::Configuration]
    def initialize
      set_defaults
    end

    # Resets all configuration options to "factory" default settings.
    #
    # @api public
    # @return [Twords::Configuration]
    # @see Twords.reset_config!
    def reset!
      tap { set_defaults }
    end

    # Configure a new Twords::TwitterClient with a configuration block.
    # If no block is given the existing client is returned unchanged.
    #
    # @api public
    # @return [Twords::TwitterClient]
    def twitter_client(&block)
      @client = TwitterClient.new(&block) if block_given?
      @client
    end

    # Set the words to be skipped during analysis.
    #
    # @param args [Array<String>] an indefinite list of words to ignore
    def rejects=(*args)
      @rejects = args.flatten.map(&:to_s)
    end

    # Set whether hashtags should be counted. If true, any word beginning with "#" will be ignored.
    #
    # @param boolean [true, false] will raise an error if the value is not a Boolean value
    def include_hashtags=(boolean)
      not_a_boolean_error(boolean)
      @include_hashtags = boolean
    end

    # Set whether URIs should be counted. If true, uses URI#regexp to match.
    #
    # @param boolean [true, false] will raise an error if the value is not a Boolean value
    def include_uris=(boolean)
      not_a_boolean_error(boolean)
      @include_uris = boolean
    end
    alias include_urls= include_uris=

    # Set whether @-mentions should be counted. If true, any word beginning with "@" will be ignored.
    #
    # @param boolean [true, false] will raise an error if the value is not a Boolean value
    def include_mentions=(boolean)
      not_a_boolean_error(boolean)
      @include_mentions = boolean
    end

    # Takes a block and stores for lazy evaluation to define the end of the time range being checked.
    # The return value of the block must respond to #to_time and return a Time object when called.
    #
    # @return [Proc]
    def up_to(&time_block)
      @up_to_block = time_block
    end

    # Calls the Proc value of #up_to_block and calls #to_time on the return value. Expects a Time object
    # to be returned.
    #
    # @return [Time]
    def up_to_time
      up_to_block.call.to_time
    end

    private

    # @api private
    def set_defaults
      ivars = %i[include_uris include_hashtags include_mentions range client up_to_block rejects]
      ivars.each { |ivar| instance_variable_set("@#{ivar}", DEFAULT_OPTIONS[ivar]) }
    end

    # @api private
    def a_boolean?(other)
      [true, false].include?(other)
    end

    # @api private
    def not_a_boolean_error(boolean)
      raise ArgumentError, 'argument must be a booolean value' unless a_boolean?(boolean)
    end
  end
end
