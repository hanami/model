require 'hanami/model/types'

module Hanami
  module Model
    module Sql
      # Types definitions for SQL databases
      #
      # @since x.x.x
      module Types
        include ROM::SQL::Types

        # Types for schema definitions
        #
        # @since x.x.x
        module Schema
          # Coercer for SQL associations target
          #
          # @since x.x.x
          # @api private
          class AssociationType < Hanami::Model::Types::Schema::CoercibleType
            # Check if value can be coerced
            #
            # @param value [Object] the value
            #
            # @return [TrueClass,FalseClass] the result of the check
            #
            # @since x.x.x
            # @api private
            def valid?(value)
              value.inspect =~ /\[#{primitive}\]/ || super
            end

            # @since x.x.x
            # @api private
            def success(*args)
              result(Dry::Types::Result::Success, primitive.new(args.first.to_h))
            end
          end
        end
      end
    end
  end
end
