# frozen_string_literal: true

require 'twords/configuration'
require 'twords/instance_methods'
require 'twords/version'

# Twords.config do |config|
#   config.rejects = %w[my us we an w/ because b/c or are this is from
#                       be on the for to and at our of in rt a with &amp;
#                       that it by as if was]
#
#   config.range   = 30
#   config.up_to { Time.now }
#   config.include_hashtags = false
#   config.include_uris     = false
#   config.include_mentions = false
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
# # => { "pizza"=>32, "burger"=>28, "pups"=>36, ... }
class Twords
  def self.config
    @configuration ||= Configuration.new
    @configuration.tap { |config| yield config if block_given? }
  end

  def self.reset_config!
    config.reset!
  end

  def self.client
    config.client
  end
end
