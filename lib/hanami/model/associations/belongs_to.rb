require 'hanami/model/types'

module Hanami
  module Model
    module Associations
      # Many-To-One association
      #
      # @since x.x.x
      # @api private
      class BelongsTo
        # @since x.x.x
        # @api private
        def self.schema_type(entity)
          Sql::Types::Schema::AssociationType.new(entity)
        end
      end
    end
  end
end
