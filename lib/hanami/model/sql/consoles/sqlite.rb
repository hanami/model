require_relative 'abstract'
require 'shellwords'

module Hanami
  module Model
    module Sql
      module Consoles
        # SQLite adapter
        #
        # @since x.x.x
        # @api private
        class Sqlite < Abstract
          # @since x.x.x
          # @api private
          COMMAND = 'sqlite3'.freeze

          # @since x.x.x
          # @api private
          def connection_string
            concat(command, ' ', host, database)
          end

          private

          # @since x.x.x
          # @api private
          def command
            COMMAND
          end

          # @since x.x.x
          # @api private
          def host
            @uri.host unless @uri.host.nil?
          end

          # @since x.x.x
          # @api private
          def database
            Shellwords.escape(@uri.path)
          end
        end
      end
    end
  end
end
