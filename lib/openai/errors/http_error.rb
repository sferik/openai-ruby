require "json"
require_relative "error"

module OpenAI
  class HTTPError < Error
    JSON_CONTENT_TYPE_REGEXP = %r{application/(problem\+|)json}

    attr_reader :response, :code

    def initialize(response:)
      super(error_message(response))
      @response = response
      @code = response.code
    end

    def error_message(response)
      if json?(response)
        message_from_json_response(response)
      else
        response.message
      end
    end

    def message_from_json_response(response)
      response_object = JSON.parse(response.body)
      if response_object.key?("title") && response_object.key?("detail")
        "#{response_object.fetch("title")}: #{response_object.fetch("detail")}"
      elsif response_object.key?("error")
        response_object.fetch("error")
      elsif response_object["errors"].instance_of?(Array)
        response_object.fetch("errors").map { |error| error.fetch("message") }.join(", ")
      else
        response.message
      end
    end

    def json?(response)
      JSON_CONTENT_TYPE_REGEXP.match?(response["content-type"])
    end
  end
end
