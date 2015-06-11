require 'uri'

module Lotus
  module Model
    module Migrator
      class Adapter
        MIGRATIONS_TABLE = 'schema_migrations'.freeze

        def self.for(connection)
          case connection.database_type
          when :sqlite
            require 'lotus/model/migrator/sqlite_adapter'
            SQLiteAdapter
          when :postgres
            require 'lotus/model/migrator/postgres_adapter'
            PostgresAdapter
          when :mysql
            require 'lotus/model/migrator/mysql_adapter'
            MySQLAdapter
          else
            self
          end.new(connection)
        end

        def initialize(connection)
          @connection = connection
        end

        def create
          raise MigrationError.new("Current adapter (#{ @connection.database_type }) doesn't support create.")
        end

        def drop
          raise MigrationError.new("Current adapter (#{ @connection.database_type }) doesn't support drop.")
        end

        def drop
          raise MigrationError.new("Current adapter (#{ @connection.database_type }) doesn't support dump.")
        end

        private

        def new_connection
          uri = URI.parse(@connection.uri)
          scheme, userinfo, host, port = uri.select(:scheme, :userinfo, :host, :port)

          uri  = "#{ scheme }://"
          uri += "#{ userinfo }@" unless userinfo.nil?
          uri += host
          uri += ":#{ port }" unless port.nil?

          Sequel.connect(uri)
        end

        def database
          options.fetch(:database)
        end

        def username
          options.fetch(:user)
        end

        def password
          options.fetch(:password)
        end

        def schema
          Model.configuration.schema
        end

        def options
          @connection.opts
        end

        def migrations_table
          MIGRATIONS_TABLE
        end
      end
    end
  end
end
