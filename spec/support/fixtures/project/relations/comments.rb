# frozen_string_literal: true

module Project
  module Relations
    class Comments < Hanami::Relation[:sql]
      auto_struct true
      struct_namespace Project::Entities

      schema(:comments, infer: true) do
        associations do
          belongs_to :user
          belongs_to :post
        end
      end
    end
  end
end
