require 'hanami/logger'

module Hanami
  module Model
    class Migrator
      # Automatic logger for migrations
      #
      # @since x.x.x
      # @api private
      class Logger < Hanami::Logger
        # Formatter for migrations logger
        #
        # @since x.x.x
        # @api private
        class Formatter < Hanami::Logger::Formatter
          private

          # @since x.x.x
          # @api private
          def _format(hash)
            "[migration] [#{hash.fetch(:severity)}] #{hash.fetch(:message)}\n"
          end
        end

        # @since x.x.x
        # @api private
        def initialize(stream)
          super(nil, stream: stream, formatter: Formatter.new)
        end
      end
    end
  end
end
