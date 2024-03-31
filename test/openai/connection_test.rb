require "net/http"
require "uri"
require_relative "../test_helper"

module OpenAI
  class ConnectionTest < Minitest::Test
    cover Connection

    def setup
      @connection = Connection.new
    end

    def test_initialization_defaults
      assert_equal Connection::DEFAULT_OPEN_TIMEOUT, @connection.open_timeout
      assert_equal Connection::DEFAULT_READ_TIMEOUT, @connection.read_timeout
      assert_equal Connection::DEFAULT_WRITE_TIMEOUT, @connection.write_timeout
      assert_equal Connection::DEFAULT_DEBUG_OUTPUT, @connection.debug_output
      assert_nil @connection.proxy_url
    end

    def test_custom_initialization
      connection = Connection.new(open_timeout: 10, read_timeout: 20, write_timeout: 30, debug_output: $stderr,
        proxy_url: "http://example.com:8080")

      assert_equal 10, connection.open_timeout
      assert_equal 20, connection.read_timeout
      assert_equal 30, connection.write_timeout
      assert_equal $stderr, connection.debug_output
      assert_equal "http://example.com:8080", connection.proxy_url
    end

    def test_http_client_defaults
      http_client = @connection.send(:build_http_client)

      assert_equal Connection::DEFAULT_HOST, http_client.address
      assert_equal Connection::DEFAULT_PORT, http_client.port
      assert_equal Connection::DEFAULT_OPEN_TIMEOUT, http_client.open_timeout
      assert_equal Connection::DEFAULT_READ_TIMEOUT, http_client.read_timeout
      assert_equal Connection::DEFAULT_WRITE_TIMEOUT, http_client.write_timeout
    end

    def test_debug_output
      http_client = @connection.send(:build_http_client)

      assert_equal Connection::DEFAULT_DEBUG_OUTPUT, http_client.instance_variable_get(:@debug_output)
    end

    def test_proxy
      @connection.proxy_url = "http://user:pass@example.com:8080"

      assert_equal URI("http://user:pass@example.com:8080"), @connection.proxy_uri
      assert_equal "example.com", @connection.proxy_host
      assert_equal "user", @connection.proxy_user
      assert_equal "pass", @connection.proxy_pass
      assert_equal 8080, @connection.proxy_port
    end

    def test_host_port_with_proxy
      connection = Connection.new(proxy_url: "https://user:pass@example.com")
      http_client = connection.send(:build_http_client, "example.com", 8080)

      assert_predicate http_client, :proxy?
      assert_equal "example.com", http_client.address
      assert_equal 8080, http_client.port
    end

    def test_client_properties
      connection = Connection.new(open_timeout: 10, read_timeout: 20, write_timeout: 30, debug_output: $stderr,
        proxy_url: "https://proxy.com")
      http_client = connection.send(:build_http_client)

      assert_predicate http_client, :proxy?
      assert_equal 10, http_client.open_timeout
      assert_equal 20, http_client.read_timeout
      assert_equal 30, http_client.write_timeout
      assert_equal $stderr, http_client.instance_variable_get(:@debug_output)
    end

    def test_invalid_proxy_url
      error = assert_raises(ArgumentError) { @connection.proxy_url = "ftp://ftp.openai.com/" }

      assert_equal "Invalid proxy URL: ftp://ftp.openai.com/", error.message
    end

    def test_proxy_settings_are_respected_in_http_client
      @connection.proxy_url = "http://user:pass@example.com:8080"
      http_client = @connection.send(:build_http_client)

      assert_equal "example.com", http_client.proxy_address
      assert_equal 8080, http_client.proxy_port
      assert_equal "user", http_client.proxy_user
      assert_equal "pass", http_client.proxy_pass
    end

    def test_set_env_proxy
      old_value = ENV.fetch("http_proxy", nil)
      ENV["http_proxy"] = "https://user:pass@example.com:8080"
      http_client = Connection.new.send(:build_http_client)

      assert_predicate http_client, :proxy?
      assert_equal "user", http_client.proxy_user
      assert_equal "pass", http_client.proxy_pass
      assert_equal "example.com", http_client.proxy_address
      assert_equal 8080, http_client.proxy_port
    ensure
      ENV["http_proxy"] = old_value
    end

    def test_perform
      stub_request(:get, "http://example.com:80")
      request = Net::HTTP::Get.new(URI("http://example.com:80"))
      @connection.perform(request:)

      assert_requested :get, "http://example.com:80"
    end

    def test_network_error
      stub_request(:get, "https://example.com").to_raise(Errno::ECONNREFUSED)
      request = Net::HTTP::Get.new(URI("https://example.com"))
      error = assert_raises(NetworkError) { @connection.perform(request:) }

      assert_equal "Network error: Connection refused - Exception from WebMock", error.message
    end

    def test_no_host_or_port
      stub_request(:get, "http://api.openai.com:443/v1/models")
      request = Net::HTTP::Get.new(URI("http://api.openai.com:443/v1/models"))
      request.stub(:uri, URI("/v1/models")) { @connection.perform(request:) }

      assert_requested :get, "http://api.openai.com:443/v1/models"
    end
  end
end
