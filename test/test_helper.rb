$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

unless $PROGRAM_NAME.end_with?("mutant")
  require "simplecov"

  SimpleCov.start do
    add_filter "test"
    minimum_coverage(100)
  end
end

require "minitest/autorun"
require "mutant/minitest/coverage"
require "webmock/minitest"
require "openai"

TEST_BEARER_TOKEN = "TEST_BEARER_TOKEN".freeze
