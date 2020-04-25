module Project
  module Relations
    class Categories < Hanami::Relation[:sql]
      schema(:categories, infer: true) do
        associations do
          has_many :book_ontologies
          has_many :books, through: :book_ontologies
        end
      end
    end
  end
end