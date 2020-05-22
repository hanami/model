# frozen_string_literal: true

module Project
  module Relations
    class Colors < Hanami::Relation[:sql]
      schema(:colors) do
        attribute :id,         Hanami::Model::Sql::Types::Integer
        attribute :name,       Hanami::Model::Sql::Types::String
        attribute :created_at, Hanami::Model::Sql::Types::DateTime
        attribute :updated_at, Hanami::Model::Sql::Types::DateTime
      end
    end
  end
end
