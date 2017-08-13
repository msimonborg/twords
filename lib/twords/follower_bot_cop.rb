require 'csv'
require 'twords/config_accessible'

class Twords
  class FollowerBotCop
    include ConfigAccessible

    attr_reader :screen_name, :followers, :follower_bots

    def initialize(screen_name)
      @screen_name   = screen_name
      @followers     = []
      @follower_bots = []
    end

    def client
      config.client.client
    end

    def detect_bots(cursor: nil)
      response = client.followers(screen_name, count: 200, cursor: cursor)
      count_followers_and_bots(response)
      next_cursor = response.attrs[:next_cursor]
      return if next_cursor == 0
      detect_bots(cursor: next_cursor)
    rescue Twitter::Error::TooManyRequests => error
      wait_out_rate_limit_error(error)
      retry
    end

    def count_followers_and_bots(response)
      response.attrs[:users].each do |user|
        @followers << user
        @follower_bots << user if a_bot?(user)
      end
    end

    def wait_out_rate_limit_error(error)
      reset_time = error.rate_limit.reset_in + 1
      puts "Out of #{followers.count} followers, #{follower_bots.count} bots detected."
      puts "That's a rate of #{percentage} out of 100."
      puts "Hit rate limit, waiting #{reset_time} seconds.  "
      sleep reset_time
    end

    def a_bot?(user)
      if user[:statuses_count] <= 10
        user[:default_profile_image] == true ||
        user[:followers_count].zero? ||
        bot_like_timeline?(user)
      end
    end

    def bot_like_timeline?(user)
      return true if user[:statuses_count].zero?
      return false if user[:protected] == true
      timeline = client.user_timeline(user[:screen_name])
      timeline.all? { |tweet| tweet.reply? || tweet.retweet? }
    end

    def percentage
      return 0.0 if followers.count.zero?
      (follower_bots.count / followers.count.to_f * 100).round(2)
    end
  end
end
