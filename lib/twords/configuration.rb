# frozen_string_literal: true

require 'twitter'
require 'twords/twitter_client'

class Twords
  # Configuration object
  class Configuration
    DEFAULT_REJECTS = %w[
      my us we an w/ because
      b/c or are this is from
      be on the for to and at
      our of in rt a with &amp;
      that it by as if was
    ].freeze

    DEFAULT_TWITTER_CONFIG = lambda do |twitter|
      twitter.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
      twitter.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
      twitter.access_token        = ENV['TWITTER_ACCESS_TOKEN']
      twitter.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
    end

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

    def initialize
      set_defaults
    end

    def reset!
      tap { set_defaults }
    end

    def twitter_client(&block)
      @client = TwitterClient.new(&block)
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
    alias include_urls= include_uris=

    def include_mentions=(boolean)
      not_a_boolean_error(boolean)
      @include_mentions = boolean
    end

    def up_to(&time_block)
      @up_to_block = time_block
    end

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
