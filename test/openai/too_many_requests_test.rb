require_relative "../test_helper"

module OpenAI
  class TooManyRequestsTest < Minitest::Test
    cover TooManyRequests

    def setup
      Time.stub :now, Time.utc(1983, 11, 24) do
        response = Net::HTTPTooManyRequests.new("1.1", 429, "Too Many Requests")
        response["x-rate-limit-limit"] = "100"
        response["x-rate-limit-remaining"] = "0"
        response["x-rate-limit-reset"] = (Time.now + 60).to_i.to_s

        @exception = TooManyRequests.new(response:)
      end
    end

    def test_initialize_with_empty_response
      response = Net::HTTPTooManyRequests.new("1.1", 429, "Too Many Requests")
      exception = TooManyRequests.new(response:)

      assert_equal 0, exception.rate_limits.count
      assert_equal Time.at(0).utc, exception.reset_at
      assert_equal 0, exception.reset_in
      assert_equal "Too Many Requests", exception.message
    end

    def test_rate_limit
      Time.stub :now, Time.utc(1983, 11, 24) do
        @exception.response["x-app-limit-24hour-reset"] = (Time.now + 61).to_i.to_s
        @exception.response["x-app-limit-24hour-remaining"] = "0"

        assert_equal Time.now + 61, @exception.rate_limit.reset_at
      end
    end

    def test_rate_limits
      Time.stub :now, Time.utc(1983, 11, 24) do
        @exception.response["x-app-limit-24hour-limit"] = "200"
        @exception.response["x-app-limit-24hour-remaining"] = "0"
        limits = @exception.rate_limits

        assert_equal 2, limits.count
        assert_equal "rate-limit", limits.first.type
        assert_equal "app-limit-24hour", limits.last.type
      end
    end

    def test_rate_limits_exlude_non_exhausted_limits
      Time.stub :now, Time.utc(1983, 11, 24) do
        @exception.response["x-app-limit-24hour-limit"] = "200"
        @exception.response["x-app-limit-24hour-remaining"] = "1"
        limits = @exception.rate_limits

        assert_equal 1, limits.count
        assert_equal "rate-limit", limits.first.type
      end
    end

    def test_reset_at
      Time.stub :now, Time.utc(1983, 11, 24) do
        @exception.response["x-app-limit-24hour-remaining"] = "0"
        @exception.response["x-app-limit-24hour-reset"] = (Time.now + 200).to_i.to_s

        assert_equal Time.at(Time.now.to_i + 200), @exception.reset_at
      end
    end

    def test_reset_in
      Time.stub :now, Time.utc(1983, 11, 24) do
        @exception.response["x-app-limit-24hour-remaining"] = "0"
        @exception.response["x-app-limit-24hour-reset"] = (Time.now + 200).to_i.to_s

        assert_equal 200, @exception.reset_in
      end
    end

    def test_reset_in_ceil
      @exception.response["x-rate-limit-reset"] = (Time.now + 61).to_i.to_s

      assert_equal 61, @exception.reset_in
    end

    def test_retry_after
      Time.stub :now, Time.utc(1983, 11, 24) do
        @exception.response["x-app-limit-24hour-remaining"] = "0"
        @exception.response["x-app-limit-24hour-reset"] = (Time.now + 200).to_i.to_s

        assert_equal 200, @exception.retry_after
      end
    end
  end
end
