require_relative "../test_helper"

module OpenAI
  class RedirectHandlerTest < Minitest::Test
    cover RedirectHandler

    def setup
      @connection = Connection.new
      @request_builder = RequestBuilder.new
      @redirect_handler = RedirectHandler.new(connection: @connection, request_builder: @request_builder)
    end

    def test_initialize_with_defaults
      redirect_handler = RedirectHandler.new

      assert_instance_of Connection, redirect_handler.connection
      assert_instance_of RequestBuilder, redirect_handler.request_builder
    end

    def test_handle_with_no_redirects
      request = Net::HTTP::Get.new("/some_path")

      response = Net::HTTPSuccess.new("1.1", "200", "OK")

      assert_equal(response, @redirect_handler.handle(response:, request:, base_url: "http://example.com"))
    end

    def test_handle_with_one_redirect
      authenticator = BearerTokenAuthenticator.new(bearer_token: TEST_BEARER_TOKEN)
      request = Net::HTTP::Get.new("/")
      stub_request(:get, "http://www.example.com/").with(headers: {"Authorization" => /Bearer #{TEST_BEARER_TOKEN}/o})

      response = Net::HTTPFound.new("1.1", "302", "Found")
      response["Location"] = "http://www.example.com"

      @redirect_handler.handle(response:, request:, base_url: "http://example.com", authenticator:)

      assert_requested :get, "http://www.example.com"
    end

    def test_handle_with_two_redirects
      request = Net::HTTP::Delete.new("/")
      stub_request(:delete, "http://example.com/2").to_return(status: 307, headers: {"Location" => "http://example.com/3"})
      stub_request(:delete, "http://example.com/3")

      response = Net::HTTPFound.new("1.1", "307", "Found")
      response["Location"] = "http://example.com/2"

      @redirect_handler.handle(response:, request:, base_url: "http://example.com")

      assert_requested :delete, "http://example.com/2"
      assert_requested :delete, "http://example.com/3"
    end

    def test_handle_with_relative_url
      request = Net::HTTP::Get.new("/some_path")
      stub_request(:get, "http://example.com/some_relative_path")

      response = Net::HTTPFound.new("1.1", "302", "Found")
      response["Location"] = "/some_relative_path"

      @redirect_handler.handle(response:, request:, base_url: "http://example.com")

      assert_requested :get, "http://example.com/some_relative_path"
    end

    def test_handle_with_301_moved_permanently
      request = Net::HTTP::Get.new("/some_path")
      stub_request(:get, "http://example.com/new_path")

      response = Net::HTTPMovedPermanently.new("1.1", "301", "Moved Permanently")
      response["Location"] = "http://example.com/new_path"

      @redirect_handler.handle(response:, request:, base_url: "http://example.com")

      assert_requested :get, "http://example.com/new_path"
    end

    def test_handle_with_302_found
      request = Net::HTTP::Get.new("/some_path")
      stub_request(:get, "http://example.com/temp_path")

      response = Net::HTTPFound.new("1.1", "302", "Found")
      response["Location"] = "http://example.com/temp_path"

      @redirect_handler.handle(response:, request:, base_url: "http://example.com")

      assert_requested :get, "http://example.com/temp_path"
    end

    def test_handle_with_303_see_other
      request = Net::HTTP::Post.new("/some_path")
      stub_request(:post, "http://example.com/some_path")
      stub_request(:get, "http://example.com/other_path")

      response = Net::HTTPSeeOther.new("1.1", "303", "See Other")
      response["Location"] = "http://example.com/other_path"

      @redirect_handler.handle(response:, request:, base_url: "http://example.com")

      assert_requested :get, "http://example.com/other_path"
    end

    def test_handle_with_307_temporary_redirect
      request = Net::HTTP::Post.new("/some_path")
      request.body = "request_body"
      stub_request(:post, "http://example.com/temp_path")

      response = Net::HTTPTemporaryRedirect.new("1.1", "307", "Temporary Redirect")
      response["Location"] = "http://example.com/temp_path"

      @redirect_handler.handle(response:, request:, base_url: "http://example.com")

      assert_requested :post, "http://example.com/temp_path", body: "request_body"
    end

    def test_handle_with_308_permanent_redirect
      request = Net::HTTP::Post.new("/some_path")
      request.body = "request_body"
      stub_request(:post, "http://example.com/new_path")

      response = Net::HTTPPermanentRedirect.new("1.1", "308", "Permanent Redirect")
      response["Location"] = "http://example.com/new_path"

      @redirect_handler.handle(response:, request:, base_url: "http://example.com")

      assert_requested :post, "http://example.com/new_path", body: "request_body"
    end

    def test_handle_with_too_many_redirects
      request = Net::HTTP::Get.new("/some_path")
      stub_request(:get, "http://example.com/some_path").to_return(status: 302, headers: {"Location" => "http://example.com/some_path"})

      response = Net::HTTPFound.new("1.1", "302", "Found")
      response["Location"] = "http://example.com/some_path"

      e = assert_raises(TooManyRedirects) do
        @redirect_handler.handle(response:, request:, base_url: "http://example.com")
      end

      assert_equal "Too many redirects", e.message
      assert_requested :get, "http://example.com/some_path", times: RedirectHandler::DEFAULT_MAX_REDIRECTS + 1
    end
  end
end
