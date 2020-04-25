# frozen_string_literal: true

module Project
  module Relations
    class Users < Hanami::Relation[:sql]
      schema(:users, infer: true)
    end
  end
end
