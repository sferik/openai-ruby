module OpenAI
  Choice = Struct.new(:finish_reason, :index, :logprobs, :text, keyword_init: true)
end
