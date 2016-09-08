require 'uri'

module Hanami
  module Model
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
            require 'hanami/model/sql/consoles/sqlite'
            Sql::Consoles::Sqlite.new(@uri)
          when 'postgres'
            require 'hanami/model/sql/consoles/postgresql'
            Sql::Consoles::Postgresql.new(@uri)
          when 'mysql', 'mysql2'
            require 'hanami/model/sql/consoles/mysql'
            Sql::Consoles::Mysql.new(@uri)
          end
        end
      end
    end
  end
end
