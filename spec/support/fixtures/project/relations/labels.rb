# frozen_string_literal: true

module Project
  module Relations
    class Labels < Hanami::Relation[:sql]
      schema(:labels, infer: true)
    end
  end
end
