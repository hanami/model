# frozen_string_literal: true

module Project
  module Relations
    class Posts < Hanami::Relation[:sql]
      auto_struct true
      struct_namespace Project::Entities

      schema(:posts, infer: true) do
        associations do
          belongs_to :user, as: :author
          has_many :comments
          has_many :users, through: :comments, as: :commenters
        end
      end
    end
  end
end
