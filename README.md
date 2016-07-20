# WTSReader-Cli-Gem

----

## Gem Overview

----

Web To Speech Reader Cli gem uses OS X text-to-speech capabilities to read
certain web pages to the user.
For best results please limit usage to [The Guardian News US](https://www.theguardian.com/us) 
and [The Guardian News UK](http://www.newsguardian.co.uk/).
The gem takes in a web address or provides a list of sources to choose from. 
In either case the program initiates a spoken version of the content of a chosen 
web page using built in text-to-speech software on your Mac.

## Installation

----

Add this line to your application's Gemfile:

```ruby
gem 'WTSReader'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install WTSReader

## Usage

----

Run the below command and follow instructions

```
$ wts-reader
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ozPop/WTS-Reader-cli-gem. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

