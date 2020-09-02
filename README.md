# OpenAI API client library to access GPT-3 in Ruby

This is a wrapper for calling OpenAI and GPT-3's HTTP APIs. API docs are available here: https://beta.openai.com/api-docs

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'openai'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install openai

## Usage

```ruby
require "openai"

openai_client = OpenAI::Client.new(api_key: ENV.fetch("OPENAI_API_KEY"), default_engine: "ada")

# List Engines
openai_client.engines

# Retrieve Engine
openai_client.engine("babbage")

# Search
openai_client.search(documents: ["White House", "hospital", "school"], query: "the president")

# Create Completion
openai_client.completions(prompt: "Once upon a time", max_tokens: 5)
```

## TODO

* Stream Completion

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nileshtrivedi/openai.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
