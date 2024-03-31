require_relative "client_error"

module OpenAI
  class UnprocessableEntity < ClientError; end
end
