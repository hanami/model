module Lotus
  module Model
    module Adapters
      module Sql
        class Console
          extend Forwardable

          def_delegator :console, :connection_string

          def initialize(uri, options = {})
            @uri = URI.parse(uri)
            @options = options
          end

          private

          def console
            case @uri.scheme
            when 'sqlite'
              require 'lotus/model/adapters/sql/consoles/sqlite'
              Consoles::Sqlite.new(@uri, @options)
            when 'postgres'
              require 'lotus/model/adapters/sql/consoles/psql'
              Consoles::Psql.new(@uri, @options)
            when 'mysql', 'mysql2'
              require 'lotus/model/adapters/sql/consoles/mysql'
              Consoles::Mysql.new(@uri, @options)
            end
          end
        end
      end
    end
  end
end
