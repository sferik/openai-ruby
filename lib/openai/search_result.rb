module OpenAI
  SearchResult = Struct.new(:document, :object, :score, :text, keyword_init: true)
end
