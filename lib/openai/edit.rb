module OpenAI
  Edit = Struct.new(:choices, :created, :usage, :object, keyword_init: true) do
    def created_at
      Time.at(created)
    end
  end
end
