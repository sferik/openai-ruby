require "forwardable"
require "net/http"
require "openssl"
require "uri"
require_relative "errors/network_error"

module OpenAI
  class Connection
    extend Forwardable

    DEFAULT_HOST = "api.openai.com".freeze
    DEFAULT_PORT = 443
    DEFAULT_OPEN_TIMEOUT = 60 # seconds
    DEFAULT_READ_TIMEOUT = 60 # seconds
    DEFAULT_WRITE_TIMEOUT = 60 # seconds
    DEFAULT_DEBUG_OUTPUT = File.open(File::NULL, "w")
    NETWORK_ERRORS = [
      Errno::ECONNREFUSED,
      Errno::ECONNRESET,
      Net::OpenTimeout,
      Net::ReadTimeout,
      OpenSSL::SSL::SSLError
    ].freeze

    attr_accessor :open_timeout, :read_timeout, :write_timeout, :debug_output
    attr_reader :proxy_url, :proxy_uri

    def_delegator :proxy_uri, :host, :proxy_host
    def_delegator :proxy_uri, :port, :proxy_port
    def_delegator :proxy_uri, :user, :proxy_user
    def_delegator :proxy_uri, :password, :proxy_pass

    def initialize(open_timeout: DEFAULT_OPEN_TIMEOUT, read_timeout: DEFAULT_READ_TIMEOUT,
      write_timeout: DEFAULT_WRITE_TIMEOUT, debug_output: DEFAULT_DEBUG_OUTPUT, proxy_url: nil)
      @open_timeout = open_timeout
      @read_timeout = read_timeout
      @write_timeout = write_timeout
      @debug_output = debug_output
      self.proxy_url = proxy_url unless proxy_url.nil?
    end

    def perform(request:)
      host = request.uri.host || DEFAULT_HOST
      port = request.uri.port || DEFAULT_PORT
      http_client = build_http_client(host, port)
      http_client.use_ssl = request.uri.scheme.eql?("https")
      http_client.request(request)
    rescue *NETWORK_ERRORS => e
      raise NetworkError, "Network error: #{e}"
    end

    def proxy_url=(proxy_url)
      @proxy_url = proxy_url
      proxy_uri = URI(proxy_url)
      raise ArgumentError, "Invalid proxy URL: #{proxy_uri}" unless proxy_uri.is_a?(URI::HTTP)

      @proxy_uri = proxy_uri
    end

    private

    def build_http_client(host = DEFAULT_HOST, port = DEFAULT_PORT)
      http_client = if proxy_uri
        Net::HTTP.new(host, port, proxy_host, proxy_port, proxy_user, proxy_pass)
      else
        Net::HTTP.new(host, port)
      end
      configure_http_client(http_client)
    end

    def configure_http_client(http_client)
      http_client.tap do |c|
        c.open_timeout = open_timeout
        c.read_timeout = read_timeout
        c.write_timeout = write_timeout
        c.set_debug_output(debug_output)
      end
    end
  end
end
