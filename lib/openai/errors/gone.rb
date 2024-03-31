require_relative "client_error"

module OpenAI
  class Gone < ClientError; end
end
