# frozen_string_literal: true

module Project
  module Relations
    class Users < Hanami::Relation[:sql]
      schema(:users, infer: true) do
        associations { has_one :avatar }
      end
    end
  end
end
