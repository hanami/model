module Hanami
  module Model
    module Plugins
      # Transform input values into database specific types (primitives).
      #
      # @since x.x.x
      # @api private
      module Schema
        # Takes the input and applies the values transformations.
        #
        # @since x.x.x
        # @api private
        class InputWithSchema < WrappingInput
          # @since x.x.x
          # @api private
          def initialize(relation, input)
            super
            @schema = relation.schema_hash
          end

          # Processes the input
          #
          # @since x.x.x
          # @api private
          def [](value)
            @schema[value]
          end
        end

        # Class interface
        #
        # @since x.x.x
        # @api private
        module ClassMethods
          # Builds the input processor
          #
          # @since x.x.x
          # @api private
          def build(relation, options = {})
            input(InputWithSchema.new(relation, input))
            super(relation, options.merge(input: input))
          end
        end

        # @since x.x.x
        # @api private
        def self.included(klass)
          super

          klass.extend ClassMethods
        end
      end
    end
  end
end
