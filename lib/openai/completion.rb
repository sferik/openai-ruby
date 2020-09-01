module OpenAI
  Completion = Struct.new(:choices, :created, :id, :model, :object, keyword_init: true) do
    def created_at
      Time.at(created)
    end
  end
end
