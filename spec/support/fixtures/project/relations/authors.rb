# frozen_string_literal: true

module Project
  module Relations
    class Authors < Hanami::Relation[:sql]
      schema(:authors, infer: true) do
        associations do
          has_many :books
        end
      end
    end
  end
end
