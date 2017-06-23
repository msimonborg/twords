# frozen_string_literal: true

require 'twords/config_accessible'

class Twords
  # Checks if words should be counted or not
  class WordMatcher
    class << self
      include ConfigAccessible

      # Check if a word should not be counted.
      #
      # @api public
      # @return [true] if word should be skipped
      # @return [false] if word should not be skipped
      def should_be_skipped?(word)
        reject?(word) || hashtag?(word) || uri?(word) || mention?(word)
      end

      # Check if a word is one of the configured rejects to ignore
      #
      # @api public
      # @return [true] if word is a reject
      # @return [false] if word is not a reject
      def reject?(word)
        config.rejects.include?(word)
      end

      # Check if a word is a hashtag.
      #
      # @api public
      # @return [true] if hashtags should not be included and word is a hashtag
      # @return [false] if all hashtags should be included or word is not a hashtag
      def hashtag?(word)
        return false if config.include_hashtags
        !(word =~ /#(\w+)/).nil?
      end

      # Check if a word is a URI. Uses URI#regexp to match URIs
      #
      # @api public
      # @return [true] if URIs should not be included and word is a URI
      # @return [false] if all URIs should be included or word is not a URI
      def uri?(word)
        return false if config.include_uris
        !(word =~ URI.regexp).nil?
      end

      # Check if a word is a @-mention.
      #
      # @api public
      # @return [true] if @-mentions should not be included and word is a @-mention
      # @return [false] if all @-mentions should be included or word is not a @-mention
      def mention?(word)
        return false if config.include_mentions
        !(word =~ /@(\w+)/).nil?
      end
    end
  end
end
