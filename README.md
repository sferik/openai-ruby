# Openai

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

```
require 'openai'
client = Openai::Client.new(pk: "your_public_key", sk: "your_secret_key")
completions = client.completions(prompt: "Have you wondered why", max_tokens: 10)
```

This should return a Hash which is something like:

```
=> {"id"=>"cmpl-LMDA7GAlzSHvB6ZEUeFwvipv", "object"=>"text_completion", "created"=>1595276408, "model"=>"davinci:2020-05-03", "choices"=>[{"text"=>" airlines charge more for certain seats?\n\nOne", "index"=>0, "logprobs"=>nil, "finish_reason"=>"length"}]}

```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nileshtrivedi/openai.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
