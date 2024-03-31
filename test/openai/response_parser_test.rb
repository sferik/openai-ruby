require "ostruct"
require_relative "../test_helper"

module OpenAI
  class ResponseParserTest < Minitest::Test
    cover ResponseParser

    def setup
      @response_parser = ResponseParser.new
      @uri = URI("http://example.com")
    end

    def response(uri = @uri)
      Net::HTTP.get_response(uri)
    end

    def test_success_response
      stub_request(:get, @uri.to_s)
        .to_return(body: '{"message": "success"}', headers: {"Content-Type" => "application/json"})

      assert_equal({"message" => "success"}, @response_parser.parse(response:))
    end

    def test_non_json_success_response
      stub_request(:get, @uri.to_s)
        .to_return(body: "<html></html>", headers: {"Content-Type" => "text/html"})

      assert_nil @response_parser.parse(response:)
    end

    def test_that_it_parses_204_no_content_response
      stub_request(:get, @uri.to_s).to_return(status: 204)

      assert_nil @response_parser.parse(response:)
    end

    def test_bad_request_error
      stub_request(:get, @uri.to_s).to_return(status: 400)
      exception = assert_raises(BadRequest) { @response_parser.parse(response:) }

      assert_kind_of Net::HTTPBadRequest, exception.response
      assert_equal "400", exception.code
    end

    def test_unknown_error_code
      stub_request(:get, @uri.to_s).to_return(status: 418)
      assert_raises(Error) { @response_parser.parse(response:) }
    end

    def test_too_many_requests_with_headers
      stub_request(:get, @uri.to_s)
        .to_return(status: 429, headers: {"x-rate-limit-remaining" => "0"})
      exception = assert_raises(TooManyRequests) { @response_parser.parse(response:) }

      assert_predicate exception.rate_limits.first.remaining, :zero?
    end

    def test_error_with_title_only
      stub_request(:get, @uri.to_s)
        .to_return(status: [400, "Bad Request"], body: '{"title": "Some Error"}', headers: {"Content-Type" => "application/json"})
      exception = assert_raises(BadRequest) { @response_parser.parse(response:) }

      assert_equal "Bad Request", exception.message
    end

    def test_error_with_detail_only
      stub_request(:get, @uri.to_s)
        .to_return(status: [400, "Bad Request"],
          body: '{"detail": "Something went wrong"}', headers: {"Content-Type" => "application/json"})
      exception = assert_raises(BadRequest) { @response_parser.parse(response:) }

      assert_equal "Bad Request", exception.message
    end

    def test_error_with_title_and_detail_error_message
      stub_request(:get, @uri.to_s)
        .to_return(status: 400,
          body: '{"title": "Some Error", "detail": "Something went wrong"}', headers: {"Content-Type" => "application/json"})
      exception = assert_raises(BadRequest) { @response_parser.parse(response:) }

      assert_equal("Some Error: Something went wrong", exception.message)
    end

    def test_error_with_error_message
      stub_request(:get, @uri.to_s)
        .to_return(status: 400, body: '{"error": "Some Error"}', headers: {"Content-Type" => "application/json"})
      exception = assert_raises(BadRequest) { @response_parser.parse(response:) }

      assert_equal("Some Error", exception.message)
    end

    def test_error_with_errors_array_message
      stub_request(:get, @uri.to_s)
        .to_return(status: 400,
          body: '{"errors": [{"message": "Some Error"}, {"message": "Another Error"}]}', headers: {"Content-Type" => "application/json"})
      exception = assert_raises(BadRequest) { @response_parser.parse(response:) }

      assert_equal("Some Error, Another Error", exception.message)
    end

    def test_error_with_errors_message
      stub_request(:get, @uri.to_s)
        .to_return(status: 400, body: '{"errors": {"message": "Some Error"}}', headers: {"Content-Type" => "application/json"})
      exception = assert_raises(BadRequest) { @response_parser.parse(response:) }

      assert_empty exception.message
    end

    def test_non_json_error_response
      stub_request(:get, @uri.to_s)
        .to_return(status: [400, "Bad Request"], body: "<html>Bad Request</html>", headers: {"Content-Type" => "text/html"})
      exception = assert_raises(BadRequest) { @response_parser.parse(response:) }

      assert_equal "Bad Request", exception.message
    end

    def test_default_response_objects
      stub_request(:get, @uri.to_s)
        .to_return(body: '{"array": [1, 2, 2, 3]}', headers: {"Content-Type" => "application/json"})
      hash = @response_parser.parse(response:)

      assert_kind_of Hash, hash
      assert_kind_of Array, hash["array"]
      assert_equal [1, 2, 2, 3], hash["array"]
    end

    def test_custom_response_objects
      stub_request(:get, @uri.to_s)
        .to_return(body: '{"set": [1, 2, 2, 3]}', headers: {"Content-Type" => "application/json"})
      ostruct = @response_parser.parse(response:, object_class: OpenStruct, array_class: Set)

      assert_kind_of OpenStruct, ostruct
      assert_kind_of Set, ostruct.set
      assert_equal Set.new([1, 2, 3]), ostruct.set
    end
  end
end
