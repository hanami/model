# frozen_string_literal: true

module Project
  module Relations
    class Books < Hanami::Relation[:sql]
      schema(:books, infer: true) do
        associations do
          belongs_to :author
        end
      end
    end
  end
end
