module Project
  module Relations
    class Users < Hanami::Relation[:sql]
      schema(:users, infer: true)
    end
  end
end