module Project
  module Relations
    class BookOntologies < Hanami::Relation[:sql]
      schema(:book_ontologies, infer: true) do
        associations do
          belongs_to :books
          belongs_to :categories
        end
      end
    end
  end
end