require_relative "server_error"

module OpenAI
  class ServiceUnavailable < ServerError; end
end
