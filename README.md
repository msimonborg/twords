![twords](http://msimonborg.com/twords/twords.png)

## Twitter word clouds

Count the occurrences of words in a tweeter's tweets.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'twords'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install twords

## Usage

```ruby
Twords.config do |config|
  config.rejects = %w[are this is from be on the for to and at our of in rt a with &amp;] # these words will not be counted (example, not a default; you must provide your own list)
  config.range   = 14 # number of days to check, no default
  
  config.include_hashtags = false # default, excludes words beginning with '#'
  config.include_uris     = false # default, uses URI#regexp to match
  config.include_mentions = false # default, excludes words beginning with '@'
  
  config.up_to { Time.now } # The block must return an object that responds to #to_time. The time is lazy evaluated and the range is counted backward from here.
  
  config.twitter_client do |twitter|
    twitter.consumer_key        = YOUR_TWITTER_CONSUMER_KEY
    twitter.consumer_secret     = YOUR_TWITTER_CONSUMER_SECRET
    twitter.access_token        = YOUR_TWITTER_ACCESS_TOKEN
    twitter.access_token_secret = YOUR_TWITTER_ACCESS_TOKEN_SECRET
  end
end

twords = Twords.new 'user_one', 'user_two' # A list of Twitter handles to include in the count.

twords.audit
# => true

twords.words
# => { "butts"=>32, "poo"=>28, "pups"=>36, ... }

twords.words_forward # Sort descending. Alias #sort_words
# => [["pups", 36], ["butts", 32], ["poo", 28], ...]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/msimonborg/twords.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

