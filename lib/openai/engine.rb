module OpenAI
  Engine = Struct.new(:id, :object, :owner, :ready, keyword_init: true)
end
