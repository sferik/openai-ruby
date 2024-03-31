require "ostruct"
require_relative "../test_helper"

module OpenAI
  class ClientInitializationTest < Minitest::Test
    cover Client

    def setup
      @client = Client.new
    end

    def test_setting_bearer_token
      @client.bearer_token = "bearer_token"

      authenticator = @client.instance_variable_get(:@authenticator)

      assert_equal "bearer_token", @client.bearer_token
      assert_instance_of BearerTokenAuthenticator, authenticator
    end

    def test_authenticator_remains_unchanged_if_no_new_credentials
      initial_authenticator = @client.instance_variable_get(:@authenticator)

      @client.bearer_token = nil

      new_authenticator = @client.instance_variable_get(:@authenticator)

      assert_equal initial_authenticator, new_authenticator
    end

    def test_initialize_with_default_connection_options
      connection = @client.instance_variable_get(:@connection)

      assert_equal Connection::DEFAULT_OPEN_TIMEOUT, connection.open_timeout
      assert_equal Connection::DEFAULT_READ_TIMEOUT, connection.read_timeout
      assert_equal Connection::DEFAULT_WRITE_TIMEOUT, connection.write_timeout
      assert_equal Connection::DEFAULT_DEBUG_OUTPUT, connection.debug_output
      assert_nil connection.proxy_url
    end

    def test_initialize_connection_options
      client = Client.new(open_timeout: 10, read_timeout: 20, write_timeout: 30, debug_output: $stderr, proxy_url: "https://user:pass@proxy.com:42")

      connection = client.instance_variable_get(:@connection)

      assert_equal 10, connection.open_timeout
      assert_equal 20, connection.read_timeout
      assert_equal 30, connection.write_timeout
      assert_equal $stderr, connection.debug_output
      assert_equal "https://user:pass@proxy.com:42", connection.proxy_url
    end

    def test_defaults
      @client = Client.new

      assert_equal "https://api.openai.com/v1/", @client.base_url
      assert_equal 10, @client.max_redirects
      assert_equal Hash, @client.default_object_class
      assert_equal Array, @client.default_array_class
    end

    def test_overwrite_defaults
      @client = Client.new(base_url: "https://api.openai.com/v2/", max_redirects: 5, default_object_class: OpenStruct,
        default_array_class: Set)

      assert_equal "https://api.openai.com/v2/", @client.base_url
      assert_equal 5, @client.max_redirects
      assert_equal OpenStruct, @client.default_object_class
      assert_equal Set, @client.default_array_class
    end

    def test_passes_options_to_redirect_handler
      client = Client.new(max_redirects: 5)
      connection = client.instance_variable_get(:@connection)
      request_builder = client.instance_variable_get(:@request_builder)
      redirect_handler = client.instance_variable_get(:@redirect_handler)
      max_redirects = redirect_handler.instance_variable_get(:@max_redirects)

      assert_equal connection, redirect_handler.connection
      assert_equal request_builder, redirect_handler.request_builder
      assert_equal 5, max_redirects
    end
  end
end
