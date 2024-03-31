require_relative "../test_helper"

module OpenAI
  class BearerTokenAuthenticatorTest < Minitest::Test
    cover BearerTokenAuthenticator

    def setup
      @authenticator = BearerTokenAuthenticator.new(bearer_token: TEST_BEARER_TOKEN)
    end

    def test_initialize
      assert_equal TEST_BEARER_TOKEN, @authenticator.bearer_token
    end

    def test_header
      assert_kind_of Hash, @authenticator.header
      assert_equal "Bearer #{TEST_BEARER_TOKEN}", @authenticator.header["Authorization"]
    end
  end
end
