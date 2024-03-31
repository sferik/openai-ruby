require_relative "authenticator"

module OpenAI
  class BearerTokenAuthenticator < Authenticator
    attr_accessor :bearer_token

    def initialize(bearer_token:) # rubocop:disable Lint/MissingSuper
      @bearer_token = bearer_token
    end

    def header
      {AUTHENTICATION_HEADER => "Bearer #{bearer_token}"}
    end
  end
end
