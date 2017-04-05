require 'hanami/logger'

module Hanami
  module Model
    class Migrator
      # Automatic logger for migrations
      #
      # @since 1.0.0
      # @api private
      class Logger < Hanami::Logger
        # Formatter for migrations logger
        #
        # @since 1.0.0
        # @api private
        class Formatter < Hanami::Logger::Formatter
          private

          # @since 1.0.0
          # @api private
          def _format(hash)
            "[hanami] [#{hash.fetch(:severity)}] #{hash.fetch(:message)}\n"
          end
        end

        # @since 1.0.0
        # @api private
        def initialize(stream)
          super(nil, stream: stream, formatter: Formatter.new)
        end
      end
    end
  end
end
