require_relative "client_error"

module OpenAI
  class Unauthorized < ClientError; end
end
