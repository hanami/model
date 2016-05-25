require 'rom-sql'

module Hanami
  module Model
    module Sql
      module Plugins
        class WrappingInput
          def initialize(relation, input)
            @input = input || Hash
          end
        end

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

              v   = @input[value]
              now = Time.now.utc

              if v[:created_at]
                v.merge(updated_at: now)
              else
                v.merge(created_at: now, updated_at: now)
              end
            end

            private

            def timestamps?
              @timestamps
            end
          end

          module ClassMethods
            def build(relation, options = {})
              super(relation, options.merge(input: InputWithTimestamp.new(relation, input)))
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
end

ROM.plugins do
  adapter :sql do
    register :timestamps, Hanami::Model::Sql::Plugins::Timestamps, type: :command
  end
end
