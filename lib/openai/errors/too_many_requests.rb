require_relative "client_error"
require_relative "../rate_limit"

module OpenAI
  class TooManyRequests < ClientError
    def rate_limit
      rate_limits.max_by(&:reset_at)
    end

    def rate_limits
      @rate_limits ||= RateLimit::TYPES.filter_map do |type|
        RateLimit.new(type:, response:) if response["x-#{type}-remaining"].eql?("0")
      end
    end

    def reset_at
      rate_limit&.reset_at || Time.at(0)
    end

    def reset_in
      [(reset_at - Time.now).ceil, 0].max
    end

    alias_method :retry_after, :reset_in
  end
end
