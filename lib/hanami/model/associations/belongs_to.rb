require 'hanami/model/types'

module Hanami
  module Model
    module Associations
      # Many-To-One association
      #
      # @since 0.7.0
      # @api private
      class BelongsTo
        # @since 0.7.0
        # @api private
        def self.schema_type(entity)
          Sql::Types::Schema::AssociationType.new(entity)
        end
      end
    end
  end
end
