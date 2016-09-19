module Hanami
  module Model
    module Plugins
      # Automatically set/update timestamp columns for create/update commands
      #
      # @since x.x.x
      # @api private
      module Timestamps
        # Takes the input and applies the timestamp transformation.
        # This is an "abstract class", please look at the subclasses for
        # specific behaviors.
        #
        # @since x.x.x
        # @api private
        class InputWithTimestamp < WrappingInput
          # Conventional timestamp names
          #
          # @since x.x.x
          # @api private
          TIMESTAMPS = [:created_at, :updated_at].freeze

          # @since x.x.x
          # @api private
          def initialize(relation, input)
            super
            columns     = relation.columns.sort
            @timestamps = (columns & TIMESTAMPS) == TIMESTAMPS
          end

          # Processes the input
          #
          # @since x.x.x
          # @api private
          def [](value)
            return value unless timestamps?
            _touch(@input[value], Time.now)
          end

          protected

          # @since x.x.x
          # @api private
          def _touch(_value)
            raise NotImplementedError
          end

          private

          # @since x.x.x
          # @api private
          def timestamps?
            @timestamps
          end
        end

        # Updates <tt>updated_at</tt> timestamp for update commands
        #
        # @since x.x.x
        # @api private
        class InputWithUpdateTimestamp < InputWithTimestamp
          protected

          # @since x.x.x
          # @api private
          def _touch(value, now)
            value[:updated_at] = now
            value
          end
        end

        # Sets <tt>created_at</tt> and <tt>updated_at</tt> timestamps for create commands
        #
        # @since x.x.x
        # @api private
        class InputWithCreateTimestamp < InputWithUpdateTimestamp
          protected

          # @since x.x.x
          # @api private
          def _touch(value, now)
            super
            value[:created_at] = now
            value
          end
        end

        # Class interface
        #
        # @since x.x.x
        # @api private
        module ClassMethods
          # Build an input processor according to the current command (create or update).
          #
          # @since x.x.x
          # @api private
          def build(relation, options = {})
            plugin = if self < ROM::Commands::Create
                       InputWithCreateTimestamp
                     else
                       InputWithUpdateTimestamp
                     end

            input(plugin.new(relation, input))
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
