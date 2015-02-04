require 'lotus/model/adapters/sql/sqlite_console'
require 'lotus/model/adapters/sql/psql_console'
require 'lotus/model/adapters/sql/mysql_console'

module Lotus
  module Model
    module Adapters
      module Sql
        class Console
          def initialize(uri, options = {})
            @uri = URI.parse(uri)
            @options = options
          end

          def connection_string
            console.connection_string
          end

          private

          def console
            case @uri.scheme
            when 'sqlite'
              SqliteConsole.new(@uri, @options)
            when 'postgres'
              PsqlConsole.new(@uri, @options)
            when 'mysql', 'mysql2'
              MysqlConsole.new(@uri, @options)
            end
          end

        end
      end
    end
  end
end
