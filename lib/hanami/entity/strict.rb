# frozen_string_literal: true

module Hanami
  class Entity < Dry::Struct
    # Strict entity
    #
    # @since 2.0.0
    class Strict < Entity
      def self.optional!(entity)
      end
    end
  end
end
