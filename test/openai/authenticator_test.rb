require_relative "../test_helper"

module OpenAI
  class AuthenticatorTest < Minitest::Test
    cover Authenticator

    def setup
      @authenticator = Authenticator.new
    end

    def test_header
      assert_kind_of Hash, @authenticator.header
      assert_empty @authenticator.header["Authorization"]
    end
  end
end
