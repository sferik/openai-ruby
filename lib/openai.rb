require "openai/version"
require "httparty"

module Openai
  class Client
    BASE_URL = "https://api.openai.com/v1/engines/davinci"

    attr_accessor :pk, :sk

    def initialize(pk:, sk:)
      @pk, @sk = pk, sk
    end

    def completions(prompt:, max_tokens: 5)
      response = HTTParty.post(BASE_URL + "/completions", headers: self.headers, body: {
        prompt: prompt,
        max_tokens: max_tokens
      }.to_json)
      return JSON.parse(response.body)
    end

    def headers
      {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{@sk}"
      }
    end
  end
end
