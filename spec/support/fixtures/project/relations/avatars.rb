# frozen_string_literal: true

module Project
  module Relations
    class Avatars < Hanami::Relation[:sql]
      schema(:avatars, infer: true) do
        associations do
          belongs_to :users
        end
      end
    end
  end
end
