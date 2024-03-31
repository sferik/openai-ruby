require_relative "../test_helper"

module OpenAI
  class RateLimitTest < Minitest::Test
    cover RateLimit

    def setup
      Time.stub :now, Time.utc(1983, 11, 24) do
        response = {
          "x-rate-limit-limit" => "100",
          "x-rate-limit-remaining" => "0",
          "x-rate-limit-reset" => (Time.now.to_i + 60).to_s
        }
        @rate_limit = RateLimit.new(type: "rate-limit", response:)
      end
    end

    def test_limit
      assert_equal 100, @rate_limit.limit
    end

    def test_remaining
      assert_equal 0, @rate_limit.remaining
    end

    def test_reset_at
      Time.stub :now, Time.utc(1983, 11, 24) do
        assert_equal Time.at(Time.now.to_i + 60), @rate_limit.reset_at
      end
    end

    def test_reset_in
      Time.stub :now, Time.utc(1983, 11, 24) do
        assert_equal 60, @rate_limit.reset_in
      end
    end

    def test_reset_in_minimum_value
      @rate_limit.response["x-rate-limit-reset"] = (Time.now.to_i - 60).to_s

      assert_equal 0, @rate_limit.reset_in
    end

    def test_reset_in_ceil
      @rate_limit.response["x-rate-limit-reset"] = (Time.now + 61).to_i.to_s

      assert_equal 61, @rate_limit.reset_in
    end
  end
end
