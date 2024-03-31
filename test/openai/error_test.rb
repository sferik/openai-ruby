require_relative "../test_helper"

module OpenAI
  class ErrorsTest < Minitest::Test
    cover Client

    def setup
      @client = Client.new
    end

    ResponseParser::ERROR_MAP.each do |status, error_class|
      name = error_class.name.split("::").last
      define_method :"test_initialize_#{name.downcase}_error" do
        response = Net::HTTPResponse::CODE_TO_OBJ[status.to_s].new("1.1", status, error_class.name)
        exception = error_class.new(response:)

        assert_equal error_class.name, exception.message
        assert_equal response, exception.response
        assert_equal status, exception.code
      end
    end

    Connection::NETWORK_ERRORS.each do |error_class|
      define_method "test_#{error_class.name.split("::").last.downcase}_raises_network_error" do
        stub_request(:get, "https://api.openai.com/v1/models").to_raise(error_class)

        assert_raises NetworkError do
          @client.get("models")
        end
      end
    end

    def test_unexpected_response
      stub_request(:get, "https://api.openai.com/v1/models").to_return(status: 600)

      assert_raises Error do
        @client.get("models")
      end
    end

    def test_problem_json
      body = {error: "problem"}.to_json
      stub_request(:get, "https://api.openai.com/v1/models")
        .to_return(status: 400, headers: {"content-type" => "application/problem+json"}, body:)

      begin
        @client.get("models")
      rescue BadRequest => e
        assert_equal "problem", e.message
      end
    end
  end
end
