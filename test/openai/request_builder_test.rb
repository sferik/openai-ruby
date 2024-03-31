require "uri"
require_relative "../test_helper"

module OpenAI
  class RequestBuilderTest < Minitest::Test
    cover RequestBuilder

    def setup
      @authenticator = BearerTokenAuthenticator.new(bearer_token: TEST_BEARER_TOKEN)
      @request_builder = RequestBuilder.new
      @uri = URI("http://example.com")
    end

    def test_build_get_request
      request = @request_builder.build(http_method: :get, uri: @uri, authenticator: @authenticator)

      assert_equal "GET", request.method
      assert_equal @uri, request.uri
      assert_equal "Bearer TEST_BEARER_TOKEN", request["Authorization"]
      assert_equal "application/json; charset=utf-8", request["Content-Type"]
    end

    def test_build_post_request
      request = @request_builder.build(http_method: :post, uri: @uri, body: "{}", authenticator: @authenticator)

      assert_equal "POST", request.method
      assert_equal @uri, request.uri
      assert_equal "{}", request.body
      assert_equal "Bearer TEST_BEARER_TOKEN", request["Authorization"]
    end

    def test_custom_headers
      request = @request_builder.build(http_method: :get, uri: @uri,
        headers: {"User-Agent" => "Custom User Agent"}, authenticator: @authenticator)

      assert_equal "Custom User Agent", request["User-Agent"]
    end

    def test_build_without_authenticator_parameter
      request = @request_builder.build(http_method: :get, uri: @uri)

      assert_empty request["Authorization"]
    end

    def test_unsupported_http_method
      exception = assert_raises ArgumentError do
        @request_builder.build(http_method: :unsupported, uri: @uri, authenticator: @authenticator)
      end

      assert_equal "Unsupported HTTP method: unsupported", exception.message
    end

    def test_escape_query_params
      uri = "https://api.openai.com/v2/models?media_type=video/mp4"
      request = @request_builder.build(http_method: :post, uri:, authenticator: @authenticator)

      assert_equal "media_type=video%2Fmp4", request.uri.query
    end
  end
end
