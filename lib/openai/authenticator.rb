module OpenAI
  class Authenticator
    AUTHENTICATION_HEADER = "Authorization".freeze

    def header
      {AUTHENTICATION_HEADER => ""}
    end
  end
end
