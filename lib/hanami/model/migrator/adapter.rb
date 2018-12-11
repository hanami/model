require 'uri'
require 'shellwords'
require 'open3'

module Hanami
  module Model
    class Migrator
      # Migrator base adapter
      #
      # @since 0.4.0
      # @api private
      class Adapter
        # Migrations table to store migrations metadata.
        #
        # @since 0.4.0
        # @api private
        MIGRATIONS_TABLE = :schema_migrations

        # Migrations table version column
        #
        # @since 0.4.0
        # @api private
        MIGRATIONS_TABLE_VERSION_COLUMN = :filename

        # Loads and returns a specific adapter for the given connection.
        #
        # @since 0.4.0
        # @api private
        def self.for(configuration) # rubocop:disable Metrics/MethodLength
          connection = Connection.new(configuration)

          case connection.database_type
          when :sqlite
            require 'hanami/model/migrator/sqlite_adapter'
            SQLiteAdapter
          when :postgres
            require 'hanami/model/migrator/postgres_adapter'
            PostgresAdapter
          when :mysql
            require 'hanami/model/migrator/mysql_adapter'
            MySQLAdapter
          else
            self
          end.new(connection)
        end

        # Initialize an adapter
        #
        # @since 0.4.0
        # @api private
        def initialize(connection)
          @connection = connection
        end

        # Create database.
        # It must be implemented by subclasses.
        #
        # @since 0.4.0
        # @api private
        #
        # @see Hanami::Model::Migrator.create
        def create
          raise MigrationError.new("Current adapter (#{connection.database_type}) doesn't support create.")
        end

        # Drop database.
        # It must be implemented by subclasses.
        #
        # @since 0.4.0
        # @api private
        #
        # @see Hanami::Model::Migrator.drop
        def drop
          raise MigrationError.new("Current adapter (#{connection.database_type}) doesn't support drop.")
        end

        # @since 0.4.0
        # @api private
        def migrate(migrations, version)
          version = Integer(version) unless version.nil?

          Sequel::Migrator.run(connection.raw, migrations, target: version, allow_missing_migration_files: true)
        rescue Sequel::Migrator::Error => e
          raise MigrationError.new(e.message)
        end

        # @since 1.1.0
        # @api private
        def rollback(migrations, steps)
          table = migrations_table_dataset
          version = version_to_rollback(table, steps)

          Sequel::Migrator.run(connection.raw, migrations, target: version, allow_missing_migration_files: true)
        rescue Sequel::Migrator::Error => e
          raise MigrationError.new(e.message)
        end

        # Load database schema.
        # It must be implemented by subclasses.
        #
        # @since 0.4.0
        # @api private
        #
        # @see Hanami::Model::Migrator.prepare
        def load
          raise MigrationError.new("Current adapter (#{connection.database_type}) doesn't support load.")
        end

        # Database version.
        #
        # @since 0.4.0
        # @api private
        def version
          table = migrations_table_dataset
          return if table.nil?

          record = table.order(MIGRATIONS_TABLE_VERSION_COLUMN).last
          return if record.nil?

          record.fetch(MIGRATIONS_TABLE_VERSION_COLUMN).scan(MIGRATIONS_FILE_NAME_PATTERN).first.to_s
        end

        private

        # @since 1.1.0
        # @api private
        MIGRATIONS_FILE_NAME_PATTERN = /\A[\d]{14}/.freeze

        # @since 1.1.0
        # @api private
        def version_to_rollback(table, steps)
          record = table.order(Sequel.desc(MIGRATIONS_TABLE_VERSION_COLUMN)).all[steps]
          return 0 unless record

          record.fetch(MIGRATIONS_TABLE_VERSION_COLUMN).scan(MIGRATIONS_FILE_NAME_PATTERN).first.to_i
        end

        # @since 1.1.0
        # @api private
        def migrations_table_dataset
          connection.table(MIGRATIONS_TABLE)
        end

        # @since 0.5.0
        # @api private
        attr_reader :connection

        # @since 0.4.0
        # @api private
        def schema
          connection.schema
        end

        # Returns a database connection
        #
        # Given a DB connection URI we can connect to a specific database or not, we need this when creating
        # or dropping a database. Important to notice that we can't always open a _global_ DB connection,
        # because most of the times application's DB user has no rights to do so.
        #
        # @param global [Boolean] determine whether or not a connection should specify a database.
        #
        # @since 0.5.0
        # @api private
        def new_connection(global: false)
          uri = global ? connection.global_uri : connection.uri

          Sequel.connect(uri)
        end

        # @since 0.4.0
        # @api private
        def database
          escape connection.database
        end

        # @since 0.4.0
        # @api private
        def port
          escape connection.port
        end

        # @since 0.4.0
        # @api private
        def host
          escape connection.host
        end

        # @since 0.4.0
        # @api private
        def username
          escape connection.user
        end

        # @since 0.4.0
        # @api private
        def password
          escape connection.password
        end

        # @since 0.4.0
        # @api private
        def migrations_table
          escape MIGRATIONS_TABLE
        end

        # @since 0.4.0
        # @api private
        def escape(string)
          Shellwords.escape(string) unless string.nil?
        end

        # @since 1.0.2
        # @api private
        def execute(command, env: {}, error: ->(err) { raise MigrationError.new(err) })
          Open3.popen3(env, command) do |_, stdout, stderr, wait_thr|
            error.call(stderr.read) unless wait_thr.value.success?
            yield stdout if block_given?
          end
        end
      end
    end
  end
end
