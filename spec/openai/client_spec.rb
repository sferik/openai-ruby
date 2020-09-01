require_relative "../spec_helper"

RSpec.describe OpenAI::Client do
  let(:client) do
    OpenAI::Client.new(api_key: mock_api_key)
  end

  describe "Unauthorized" do
    before do
      stub_request(:get, "https://api.openai.com/v1/engines/davinci-v2")
        .with(headers: request_headers)
        .to_return(body: File.read("spec/fixtures/errors/unauthorized.json"), headers: response_headers, status: 401)
    end

    it "raises an exception" do
      expect do
        client.engine("davinci-v2")
      end.to raise_error(OpenAI::Client::Error, "Incorrect API key provided: sk-f00. You can find your API key at https://beta.openai.com.")
    end
  end

  describe "Not Found" do
    before do
      stub_request(:get, "https://api.openai.com/v1/engines/turing")
        .with(headers: request_headers)
        .to_return(body: File.read("spec/fixtures/errors/not_found.json"), headers: response_headers, status: 404)
    end

    it "raises an exception" do
      expect do
        client.engine("turing")
      end.to raise_error(OpenAI::Client::Error, "No engine with that ID: turing")
    end
  end

  describe "#default_engine" do
    it "returns the default engine" do
      expect(client.default_engine).to eq("davinci")
    end
  end

  describe "#last_response" do
    before do
      stub_request(:get, "https://api.openai.com/v1/engines/davinci")
        .with(headers: request_headers)
        .to_return(body: File.read("spec/fixtures/engine.json"), headers: response_headers)
    end

    it "returns the last response" do
      expect(client.last_response).to be_nil
      client.engine("davinci")
      last_response = client.last_response
      expect(last_response).to be_a(OpenAI::Client::LastResponse)
      expect(last_response.organization).to be_a(String)
      expect(last_response.date).to be_a(Time)
      expect(last_response.processing_ms).to be_a(Integer)
      expect(last_response.processing_ms).to be >= 0
      expect(last_response.request_id).to be_a(String)
      expect(last_response.request_id.size).to eq(32)
      expect(last_response.status_code).to eq(200)
    end
  end

  describe "#engine" do
    before do
      stub_request(:get, "https://api.openai.com/v1/engines/davinci")
        .with(headers: request_headers)
        .to_return(body: File.read("spec/fixtures/engine.json"), headers: response_headers)
    end

    it "retrieves an engine" do
      engine = client.engine("davinci")
      expect(engine.id).to eq("davinci")
      expect(engine.owner).to eq("openai")
      expect(engine.ready).to be(true)
    end
  end

  describe "#engines" do
    before do
      stub_request(:get, "https://api.openai.com/v1/engines")
        .with(headers: request_headers)
        .to_return(body: File.read("spec/fixtures/engines.json"), headers: response_headers)
    end

    it "lists engines" do
      engines = client.engines
      expect(engines).to be_an(Array)
    end
  end

  describe "#completions" do
    before do
      stub_request(:post, "https://api.openai.com/v1/engines/ada/completions")
        .with(headers: request_headers)
        .to_return(body: File.read("spec/fixtures/completions.json"), headers: response_headers)
    end

    it "creates a completion" do
      prompt = "Once upon a time"
      max_tokens = 5
      results = client.completions(prompt: prompt, max_tokens: max_tokens, engine: "ada")
      expect(results).to be_a(OpenAI::Completion)
    end
  end

  describe "#search" do
    before do
      stub_request(:post, "https://api.openai.com/v1/engines/ada/search")
        .with(headers: request_headers)
        .to_return(body: File.read("spec/fixtures/search.json"), headers: response_headers)
    end

    it "searches" do
      documents = ["White House", "hospital", "school"]
      query = "the president"
      results = client.search(documents: documents, query: query, engine: "ada")
      expect(results).to be_an(Array)
      first_result = results.first
      expect(first_result.document).to eq(0)
      expect(first_result.score).to be_a(Float)
      expect(first_result.score).to be >= 0.0
    end
  end
end
