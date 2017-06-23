![twords](http://msimonborg.com/twords/twords.png)

[![Gem Version](https://badge.fury.io/rb/twords.svg)](https://badge.fury.io/rb/twords)

## Twitter word clouds

Count the occurrences of words in a tweeter's tweets.

Configurable - set the words to ignore, the range of dates to look at, and whether to include hashtags, @-mentions, and URLs. Customize your Twitter configuration, too. Sensible defaults are provided for all options. Look at the data in different ways. Easily convert and/or export to CSV and JSON. Change configuration options on the fly and re-audit with ease.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'twords'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install twords

## Documentation

[http://rdoc.info/gems/twords][documentation]

[documentation]: http://rdoc.info/gems/twords

## Usage

Twords takes a configuration block, and if it doesn't find one it will set the following defaults:

```ruby
Twords.config do |config|
  config.rejects = %w[my us we an w/ because b/c or are this is from
                      be on the for to and at our of in rt a with &amp;
                      that it by as if was] # These words will not be counted

  config.range   = 30 # Number of days to check

  config.include_hashtags = false # Excludes strings beginning with '#'
  config.include_uris     = false # Excludes strings that match URI#regexp
  config.include_mentions = false # Excludes strings beginning with '@'

  config.up_to { Time.now } # The block must return an object that responds to #to_time. The time is lazy evaluated and the range is counted backward from here.

  # By default the Twitter client will look for keys stored as system variables by the names listed below. Feel free to change the configuration, but never hard code the keys.
  config.twitter_client do |twitter|
    twitter.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
    twitter.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
    twitter.access_token        = ENV['TWITTER_ACCESS_TOKEN']
    twitter.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
  end
end

twords = Twords.new 'user_one', 'user_two' # A list of Twitter handles to include in the count.

twords.audit
# Fetched user_one's timeline
# Fetched user_two's timeline
# => true

twords.words
# => { "pizza"=>32, "burger"=>28, "pups"=>36, ... }

twords.words_forward # Sort descending. Alias #sort_words
# => [["pups", 36], ["pizza", 32], ["burger", 28], ...]

Twords.config { |config| config.include_hashtags = true }

twords.audit
# => true

twords.words
# => { "pizza"=>32, "burger"=>28, "pups"=>36, ... }

twords.audit!
# Fetched user_one's timeline
# Fetched user_two's timeline
# => true

twords.words
# => { "#TACOSTACOSTACOS"=>14321, "pizza"=>32, "burger"=>28, "pups"=>36, ... }
```

Other useful methods:

```ruby
twords = Twords.new 'user'
twords.audit
twords.tweets # An array of the Twitter::Tweet objects included in the count
twords.total_word_count # The total combined occurrences of the included words
twords.percentages # Replace word count with the word's percentage of total words
twords.sort_percentages # Sort the above results in descending order
twords.to_[csv|json] # Generate CSV || JSON for results
twords.write_to_[csv|json](opts) # Write CSV || JSON to file.
                                 # Options - :filename writes the file to the 
                                 # specified relative path (default = 'twords_report.[csv|json]').
                                 # Other options are passed along to File#open

```
## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/msimonborg/twords.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
