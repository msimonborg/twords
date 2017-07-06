# frozen_string_literal: true

require 'twords/follower_bot_cop'
require 'twords/configuration'
require 'twords/instance_methods'
require 'twords/version'

# Count the occurrences of words in a tweeter's tweets
#
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
#       twitter.consumer_key        = YOUR_TWITTER_CONSUMER_KEY
#       twitter.consumer_secret     = YOUR_TWITTER_CONSUMER_SECRET
#       twitter.access_token        = YOUR_TWITTER_ACCESS_TOKEN
#       twitter.access_token_secret = YOUR_TWITTER_ACCESS_TOKEN_SECRET
#     end
#   end
#
#   twords = Twords.new 'user_one', 'user_two'
#
#   twords.audit
#   # => true
#
#   twords.words
#   # => { "pizza"=>32, "burger"=>28, "pups"=>36, ... }
class Twords
  # Set configuration options. The same configuration is shared accross all objects in the
  # Twords namespace. Configuration can be changed on the fly and will affect all instantiated
  # objects.
  #
  # @api public
  # for block { |config| ... }
  # @yield [Twords::Configuration] call methods on an instance of Twords::Configuration to override
  # the default configuration settings.
  # @return [Twords::Configuration]
  def self.config
    @configuration ||= Configuration.new
    @configuration.tap { |config| yield config if block_given? }
  end

  # Resets all configuration options to default settings
  #
  # @api public
  # @return [Twords::Configuration]
  def self.reset_config!
    config.reset!
  end

  # Access the Twitter client
  #
  # @api public
  # @return [Twords::TwitterClient]
  def self.client
    config.client
  end
end
