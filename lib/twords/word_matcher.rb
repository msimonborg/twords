# frozen_string_literal: true

require 'twords/config_accessible'

class Twords
  # Checks if words should be counted or not
  class WordMatcher
    class << self
      include ConfigAccessible

      def should_be_skipped?(word)
        reject?(word) || hashtag?(word) || uri?(word) || mention?(word)
      end

      def reject?(word)
        config.rejects.include?(word)
      end

      def hashtag?(word)
        return if config.include_hashtags
        !(word =~ /#(\w+)/).nil?
      end

      def uri?(word)
        return if config.include_uris
        !(word =~ URI.regexp).nil?
      end

      def mention?(word)
        return if config.include_mentions
        !(word =~ /@(\w+)/).nil?
      end
    end
  end
end
