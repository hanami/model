require_relative 'abstract'
require 'shellwords'

module Hanami
  module Model
    module Sql
      module Consoles
        # SQLite adapter
        #
        # @since 0.7.0
        # @api private
        class Sqlite < Abstract
          # @since 0.7.0
          # @api private
          COMMAND = 'sqlite3'.freeze

          # @since 0.7.0
          # @api private
          def connection_string
            concat(command, ' ', host, database)
          end

          private

          # @since 0.7.0
          # @api private
          def command
            COMMAND
          end

          # @since 0.7.0
          # @api private
          def host
            @uri.host unless @uri.host.nil?
          end

          # @since 0.7.0
          # @api private
          def database
            Shellwords.escape(@uri.path)
          end
        end
      end
    end
  end
end
