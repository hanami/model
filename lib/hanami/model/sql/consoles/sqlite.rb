require 'shellwords'

module Hanami
  module Model
    module Sql
      module Consoles
        # SQLite adapter
        #
        # @since x.x.x
        # @api private
        class Sqlite
          # @since x.x.x
          # @api private
          def initialize(uri)
            @uri = uri
          end

          # @since x.x.x
          # @api private
          def connection_string
            "sqlite3 #{@uri.host}#{database}"
          end

          private

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
