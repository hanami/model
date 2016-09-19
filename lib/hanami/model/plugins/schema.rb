module Hanami
  module Model
    module Plugins
      module Schema
        class InputWithSchema < WrappingInput
          def initialize(relation, input)
            super
            @schema = relation.schema_hash
          end

          def [](value)
            @schema[value]
          end
        end

        module ClassMethods
          def build(relation, options = {})
            input(InputWithSchema.new(relation, input))
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
