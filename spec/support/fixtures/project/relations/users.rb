# frozen_string_literal: true

module Project
  module Relations
    class Users < Hanami::Relation[:sql]
      schema(:users, infer: true) do
        associations do
          has_one :avatar
          has_many :posts, as: :threads
          has_many :comments
        end
      end
    end
  end
end
