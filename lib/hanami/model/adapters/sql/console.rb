module Hanami
  module Model
    module Adapters
      module Sql
        class Console
          extend Forwardable

          def_delegator :console, :connection_string

          def initialize(uri)
            @uri = URI.parse(uri)
          end

          private

          def console
            case @uri.scheme
            when 'sqlite'
              require 'hanami/model/adapters/sql/consoles/sqlite'
              Consoles::Sqlite.new(@uri)
            when 'postgres'
              require 'hanami/model/adapters/sql/consoles/postgresql'
              Consoles::Postgresql.new(@uri)
            when 'mysql', 'mysql2'
              require 'hanami/model/adapters/sql/consoles/mysql'
              Consoles::Mysql.new(@uri)
            end
          end
        end
      end
    end
  end
end
