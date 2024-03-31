require_relative "client_error"

module OpenAI
  class ConnectionException < ClientError; end
end
