module Hanami
  module Model
    module Plugins
      # Transform output into model domain types (entities).
      #
      # @since x.x.x
      # @api private
      module Mapping
        # Takes the output and applies the transformations
        #
        # @since x.x.x
        # @api private
        class InputWithMapping < WrappingInput
          # @since x.x.x
          # @api private
          def initialize(relation, input)
            super
            @mapping = Hanami::Model.configuration.mappings[relation.name.to_sym]
          end

          # Processes the output
          #
          # @since x.x.x
          # @api private
          def [](value)
            @mapping.process(@input[value])
          end
        end

        # Class interface
        #
        # @since x.x.x
        # @api private
        module ClassMethods
          # Builds the output processor
          #
          # @since x.x.x
          # @api private
          def build(relation, options = {})
            input(InputWithMapping.new(relation, input))
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
