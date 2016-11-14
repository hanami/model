module Hanami
  module Model
    module Plugins
      # Transform output into model domain types (entities).
      #
      # @since 0.7.0
      # @api private
      module Mapping
        # Takes the output and applies the transformations
        #
        # @since 0.7.0
        # @api private
        class InputWithMapping < WrappingInput
          # @since 0.7.0
          # @api private
          def initialize(relation, input)
            super
            @mapping = Hanami::Model.configuration.mappings[relation.name.to_sym]
          end

          # Processes the output
          #
          # @since 0.7.0
          # @api private
          def [](value)
            @mapping.process(@input[value])
          end
        end

        # Class interface
        #
        # @since 0.7.0
        # @api private
        module ClassMethods
          # Builds the output processor
          #
          # @since 0.7.0
          # @api private
          def build(relation, options = {})
            input(InputWithMapping.new(relation, input))
            super(relation, options.merge(input: input))
          end
        end

        # @since 0.7.0
        # @api private
        def self.included(klass)
          super

          klass.extend ClassMethods
        end
      end
    end
  end
end
