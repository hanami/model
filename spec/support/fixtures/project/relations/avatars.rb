# frozen_string_literal: true

module Project
  module Relations
    class Avatars < Hanami::Relation[:sql]
      struct_namespace Project::Entities
      auto_struct true

      schema(:avatars, infer: true) do
        associations do
          belongs_to :users
        end
      end
    end
  end
end
