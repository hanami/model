module Hanami
  module Model
    module Plugins
      module Mapping
        class InputWithMapping < WrappingInput
          def initialize(relation, input)
            super
            @mapping = Hanami::Model.configuration.mappings[relation.name]
          end

          def [](value)
            @mapping.process(@input[value])
          end
        end

        module ClassMethods
          def build(relation, options = {})
            input(InputWithMapping.new(relation, input))
            super(relation, options.merge(input: input))
          end
        end

        def self.included(klass)
          super

          klass.extend ClassMethods
        end
      end
    end
  end
end
