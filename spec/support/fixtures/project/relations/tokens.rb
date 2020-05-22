# frozen_string_literal: true

module Project
  module Relations
    class Tokens < Hanami::Relation[:sql]
      schema(:tokens, infer: true)
    end
  end
end
