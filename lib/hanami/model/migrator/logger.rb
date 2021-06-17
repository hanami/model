# frozen_string_literal: true

require "hanami/logger"

module Hanami
  module Model
    class Migrator
      # Automatic logger for migrations
      #
      # @since 1.0.0
      # @api private
      class Logger < Hanami::Logger
        # Messages patterns to identify errors related to both "schema_migrations" and "schema_info" absence tables.
        #   1. SQLite
        #   2. Postgres
        #   3. MySQL
        IGNORABLE_PATTERNS = [
          /(?<=no such table: )(?:schema_migrations|schema_info)/,
          /(?<=relation )(?:"schema_migrations"|"schema_info")(?= does not exist)/,
          /(\.schema_migrations\'|\.schema_info\')(?= doesn\'t exist)/
        ].freeze

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

        # @since x.x.x
        # @api public
        def error(progname = nil, &block)
          return true if _ignorable(progname)

          super(progname, &block)
        end

        private

        # @since x.x.x
        # @api private
        def _ignorable(progname)
          IGNORABLE_PATTERNS.any? { |r| progname.match?(r) }
        end
      end
    end
  end
end
