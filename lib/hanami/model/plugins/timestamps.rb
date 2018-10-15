module Hanami
  module Model
    module Plugins
      # Automatically set/update timestamp columns for create/update commands
      #
      # @since 0.7.0
      # @api private
      module Timestamps
        # Takes the input and applies the timestamp transformation.
        # This is an "abstract class", please look at the subclasses for
        # specific behaviors.
        #
        # @since 0.7.0
        # @api private
        class InputWithTimestamp < WrappingInput
          # Conventional timestamp names
          #
          # @since 0.7.0
          # @api private
          TIMESTAMPS = %i[created_at updated_at].freeze

          # @since 0.7.0
          # @api private
          def initialize(relation, input)
            super
            @timestamps = relation.columns & TIMESTAMPS
          end

          # Processes the input
          #
          # @since 0.7.0
          # @api private
          def [](value)
            return @input[value] unless timestamps?

            _touch(@input[value], Time.now)
          end

          protected

          # @since 0.7.0
          # @api private
          def _touch(_value)
            raise NotImplementedError
          end

          private

          # @since 0.7.0
          # @api private
          def timestamps?
            !@timestamps.empty?
          end
        end

        # Updates <tt>updated_at</tt> timestamp for update commands
        #
        # @since 0.7.0
        # @api private
        class InputWithUpdateTimestamp < InputWithTimestamp
          protected

          # @since 0.7.0
          # @api private
          def _touch(value, now)
            value[:updated_at] ||= now if @timestamps.include?(:updated_at)
            value
          end
        end

        # Sets <tt>created_at</tt> and <tt>updated_at</tt> timestamps for create commands
        #
        # @since 0.7.0
        # @api private
        class InputWithCreateTimestamp < InputWithUpdateTimestamp
          protected

          # @since 0.7.0
          # @api private
          def _touch(value, now)
            super
            value[:created_at] ||= now if @timestamps.include?(:created_at)
            value
          end
        end

        # Class interface
        #
        # @since 0.7.0
        # @api private
        module ClassMethods
          # Build an input processor according to the current command (create or update).
          #
          # @since 0.7.0
          # @api private
          def build(relation, options = {})
            plugin = if self < ROM::Commands::Create
                       InputWithCreateTimestamp
                     else
                       InputWithUpdateTimestamp
                     end

            wrapped_input = plugin.new(relation, options.fetch(:input) { input })
            super(relation, options.merge(input: wrapped_input))
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
