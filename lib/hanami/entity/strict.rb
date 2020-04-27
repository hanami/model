# frozen_string_literal: true

module Hanami
  class OldEntity < Dry::Struct
    # Strict entity
    #
    # @since 2.0.0
    class Strict < OldEntity
      def self.schema_policy
        lambda do |entity|
          entity.class_eval do
            schema schema.strict
          end
        end
      end
    end
  end
end
