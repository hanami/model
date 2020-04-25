# frozen_string_literal: true

module Project
  module Relations
    class Books < Hanami::Relation[:sql]
      schema(:books, infer: true) do
        associations do
          belongs_to :author
          has_many :book_ontologies
          has_many :categories, through: :book_ontologies
        end
      end
    end
  end
end
