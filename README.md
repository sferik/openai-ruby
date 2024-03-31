[![Tests](https://github.com/sferik/openai-ruby/actions/workflows/test.yml/badge.svg)](https://github.com/sferik/openai-ruby/actions/workflows/test.yml)
[![Linter](https://github.com/sferik/openai-ruby/actions/workflows/lint.yml/badge.svg)](https://github.com/sferik/openai-ruby/actions/workflows/lint.yml)
[![Mutant](https://github.com/sferik/openai-ruby/actions/workflows/mutant.yml/badge.svg)](https://github.com/sferik/openai-ruby/actions/workflows/mutant.yml)
[![Typer Checker](https://github.com/sferik/openai-ruby/actions/workflows/steep.yml/badge.svg)](https://github.com/sferik/openai-ruby/actions/workflows/steep.yml)
[![Gem Version](https://badge.fury.io/rb/openai.svg)](https://rubygems.org/gems/openai)

# A [Ruby](https://www.ruby-lang.org) interface to the [OpenAI API](https://platform.openai.com)

## Follow

For updates and announcements, follow [@sferik](https://x.com/sferik) on X.

## Installation

Install the gem and add to the application's Gemfile:

    bundle add openai

Or, if Bundler is not being used to manage dependencies:

    gem install openai

## Usage

First, obtain an API key from <https://platform.openai.com/api-keys>.

```ruby
require "openai"

# Initialize an OpenAI API client with your API secret key
openai_client = OpenAI::Client.new(bearer_token: "sk-thats1smallStep4man1giantLeap4mankind")

# Retrieve a model instance
openai_client.get("models/gpt-4")
# {"id"=>"gpt-4", "object"=>"model", "created"=>1687882411, "owned_by"=>"openai"}
```

## Features
* OAuth 2.0 Bearer Token
* Thread safety
* HTTP redirect following
* HTTP proxy support
* HTTP logging
* HTTP timeout configuration
* HTTP error handling
* Rate limit handling
* Parsing JSON into custom response objects (e.g. OpenStruct)
* Configurable base URLs for accessing different APIs/versions

## Sponsorship

By contributing to the project, you help:

1. Maintain the library: Keeping it up-to-date and secure.
2. Add new features: Enhancements that make your life easier.
3. Provide support: Faster responses to issues and feature requests.

⭐️ Bonus: Sponsors will get priority support and influence over the project roadmap. We will also list your name or your company's logo on our GitHub page.

Building and maintaining an open-source project like this takes a considerable amount of time and effort. Your sponsorship can help sustain this project. Even a small monthly donation makes a huge difference!

[Click here to sponsor this project.](https://github.com/sponsors/sferik)

## Development

1. Checkout and repo:

       git checkout git@github.com:sferik/openai-ruby.git

2. Enter the repo’s directory:

       cd openai-ruby

3. Install dependencies via Bundler:

       bin/setup

4. Run the default Rake task to ensure all tests pass:

       bundle exec rake

5. Create a new branch for your feature or bug fix:

       git checkout -b my-new-branch

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sferik/openai-ruby.

Pull requests will only be accepted if they meet all the following criteria:

1. Code must conform to [Standard Ruby](https://github.com/standardrb/standard#readme). This can be verified with:

       bundle exec rake standard

2. Code must conform to the [RuboCop rules](https://github.com/rubocop/rubocop#readme). This can be verified with:

       bundle exec rake rubocop

3. 100% C0 code coverage. This can be verified with:

       bundle exec rake test

4. 100% mutation coverage. This can be verified with:

       bundle exec rake mutant

5. RBS type signatures (in `sig/openai.rbs`). This can be verified with:

       bundle exec rake steep

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
