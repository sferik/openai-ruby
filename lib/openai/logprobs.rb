module OpenAI
  Logprobs = Struct.new(:tokens, :token_logprobs, :top_logprobs, :text_offset, keyword_init: true)
end
