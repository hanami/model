module Hanami
  module Model
    module Plugins
      module Timestamps
        class InputWithTimestamp < WrappingInput
          TIMESTAMPS = [:created_at, :updated_at].freeze

          def initialize(relation, input)
            super
            columns = relation.schema.attributes.keys.sort
            @timestamps = (columns & TIMESTAMPS) == TIMESTAMPS
          end

          def [](value)
            return value unless timestamps?
            _touch(@input[value], Time.now)
          end

          protected

          def _touch(value)
            raise NotImplementedError
          end

          private

          def timestamps?
            @timestamps
          end
        end

        class InputWithUpdateTimestamp < InputWithTimestamp
          protected

          def _touch(value, now)
            value[:updated_at] = now
            value
          end
        end

        class InputWithCreateTimestamp < InputWithUpdateTimestamp
          protected

          def _touch(value, now)
            super
            value[:created_at] = now
            value
          end
        end

        module ClassMethods
          def build(relation, options = {})
            plugin = if self < ROM::Commands::Create
                       InputWithCreateTimestamp
                     else
                       InputWithUpdateTimestamp
                     end

            super(relation, options.merge(input: plugin.new(relation, input)))
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
