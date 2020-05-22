# frozen_string_literal: true

module Project
  module Relations
    class Operators < Hanami::Relation[:sql]
      schema(:t_operator, as: :operators) do
        attribute :operator_id, Types::Integer
        attribute :s_name, Types::String

        primary_key :operator_id
      end
    end
  end
end
