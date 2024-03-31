require_relative "server_error"

module OpenAI
  class GatewayTimeout < ServerError; end
end
