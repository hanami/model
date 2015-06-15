require 'uri'
require 'shellwords'

module Lotus
  module Model
    module Migrator
      # Migrator base adapter
      #
      # @since x.x.x
      # @api private
      class Adapter
        # Migrations table to store migrations metadata.
        #
        # @since x.x.x
        # @api private
        MIGRATIONS_TABLE = :schema_migrations

        # Migrations table version column
        #
        # @since x.x.x
        # @api private
        MIGRATIONS_TABLE_VERSION_COLUMN = :filename

        # Loads and returns a specific adapter for the given connection.
        #
        # @since x.x.x
        # @api private
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

        # Initialize an adapter
        #
        # @since x.x.x
        # @api private
        def initialize(connection)
          @connection = connection
        end

        # Create database.
        # It must be implemented by subclasses.
        #
        # @since x.x.x
        # @api private
        #
        # @see Lotus::Model::Migrator.create
        def create
          raise MigrationError.new("Current adapter (#{ @connection.database_type }) doesn't support create.")
        end

        # Drop database.
        # It must be implemented by subclasses.
        #
        # @since x.x.x
        # @api private
        #
        # @see Lotus::Model::Migrator.drop
        def drop
          raise MigrationError.new("Current adapter (#{ @connection.database_type }) doesn't support drop.")
        end

        # Load database schema.
        # It must be implemented by subclasses.
        #
        # @since x.x.x
        # @api private
        #
        # @see Lotus::Model::Migrator.prepare
        def load
          raise MigrationError.new("Current adapter (#{ @connection.database_type }) doesn't support load.")
        end

        # Database version.
        #
        # @since x.x.x
        # @api private
        def version
          return unless @connection.tables.include?(MIGRATIONS_TABLE)

          if record = @connection[MIGRATIONS_TABLE].order(MIGRATIONS_TABLE_VERSION_COLUMN).last
            record.fetch(MIGRATIONS_TABLE_VERSION_COLUMN).scan(/\A[\d]{14}/).first.to_s
          end
        end

        private

        # @since x.x.x
        # @api private
        def new_connection
          uri = URI.parse(@connection.uri)
          scheme, userinfo, host, port = uri.select(:scheme, :userinfo, :host, :port)

          uri  = "#{ scheme }://"
          uri += "#{ userinfo }@" unless userinfo.nil?
          uri += host
          uri += ":#{ port }" unless port.nil?

          Sequel.connect(uri)
        end

        # @since x.x.x
        # @api private
        def database
          escape options.fetch(:database)
        end

        # @since x.x.x
        # @api private
        def host
          escape options.fetch(:host)
        end

        # @since x.x.x
        # @api private
        def port
          escape options.fetch(:port)
        end

        # @since x.x.x
        # @api private
        def username
          escape options.fetch(:user)
        end

        # @since x.x.x
        # @api private
        def password
          escape options.fetch(:password)
        end

        # @since x.x.x
        # @api private
        def schema
          Model.configuration.schema
        end

        # @since x.x.x
        # @api private
        def migrations_table
          escape MIGRATIONS_TABLE
        end

        # @since x.x.x
        # @api private
        def options
          @connection.opts
        end

        # @since x.x.x
        # @api private
        def escape(string)
          Shellwords.escape(string) unless string.nil?
        end
      end
    end
  end
end
