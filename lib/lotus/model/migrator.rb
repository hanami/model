require 'sequel'
require 'lotus/model/migration'
require 'lotus/model/migration/file'

module Lotus
  module Model
    # The +Migrator+ class performs migrations/rollingback on a folder
    # with migration files that comply with timestamp format:
    #
    #   <yyyymmddhhmmss>_<title>.rb
    #
    # For example:
    #
    #   20150122124517_create_users.rb
    #
    # Please be noted that timestamp must be unique.
    #
    # The migration file must extend +Lotus::Model::Migration+ and
    # implement +up+ and +down+ methods.
    # @see Lotus::Model::Migration
    #
    # Migrator reads the model configuration for SQL adapter connection,
    # migration files and optional logger (default to nil).
    # @see Lotus::Model::Configuration#adapter
    # @see Lotus::Model::Configuration#migrations_directory
    # @see Lotus::Model::Configuration#logging
    #
    # @example Configure model framework
    #   Lotus::Model.configure do
    #     logging ::Logger.new(STDOUT)
    #     migrations_directory 'db/migrations'
    #     adapter type: :sql, uri: 'sqlite3://localhost/database'
    #   end
    #
    # To apply a migrator in either up or down direction, the model configuration
    # must be configured before the constuctor instantiated the object.
    # Method +run+ takes current version and target version and migrate
    # the migrations accordingly.
    #
    # If no current version is supplied, it is read from the database.
    # The migrator automatically create schema_migration table to
    # keep track of current migration version. If no migration is
    # stored in the database, the version is considered to be 0.
    # if no target version is specified, the database is migrated
    # to the latest version available in migration directory.
    #
    # The implementation borrows much code from Sequel::Migrator.
    #
    # @example Migrate all migrations in db/migrations to latest
    #   require 'lotus/model'
    #   require 'lotus/model/migrator'
    #
    #   Lotus::Model.configure do
    #     adapter type: :sql, uri: 'sqlite3://localhost/database'
    #   end
    #
    #   Lotus::Model::Migrator.new.run
    #
    # @since x.x.x
    # @see Sequel::Migration
    class Migrator
      # The framework configuration
      #
      # @since x.x.x
      # @api private
      include Utils::ClassAttribute
      class_attribute :configuration

      # It's raised when migration does not support the adapter
      #
      # @since x.x.x
      class UnsupportedAdapterError < ::StandardError
        def initialize(adapter_type)
          super("Adapter #{adapter_type} is not supported")
        end
      end

      # It's raised when adapter is not configured
      #
      # @since x.x.x
      class MissingAdapterConfigurationError < ::StandardError
        def initialize
          super('Please configure your adapter. See Lotus::Model.configure for more details')
        end
      end

      # It's raised when there are missing migration files
      #
      # @since x.x.x
      class MissingMigrationsError < ::StandardError
        def initialize(missing_migration_files)
          super("Applied migration files not in file system: #{missing_migration_files.map { |f| f.path }.join(', ')}")
        end
      end

      # Error for duplicated versions in migration files
      # It's raised when there are duplication in versionings
      #
      # @since x.x.x
      #
      # @see Lotus::Model::Migrator#run
      class DuplicatedVersionsError < ::StandardError
      end

      # The list of supported adapters
      #
      # @since x.x.x
      SUPPORTED_ADAPTERS = [:sql].freeze

      # The default column for schema migrations table
      #
      # @since x.x.x
      SCHEMA_COLUMN = :version

      # The default table for scheme migrations
      #
      # @since x.x.x
      SCHEMA_TABLE = :schema_migrations

      def initialize(opts={})
        _copy_framework_configuration
        _check_if_adapter_is_configured
        _check_if_adapter_support_migration

        @adapter = _get_adapter
        @db = adapter.connection
        @logger = _get_logger
        @directory = _get_migrations_directory
        @allow_missing_migration_files = opts[:allow_missing_migration_files]
        @files = _get_migration_files
        @column = SCHEMA_COLUMN
        schema, table = @db.schema_and_table(SCHEMA_TABLE)
        @table = schema ? Sequel::SQL::QualifiedIdentifier.new(schema, table) : table
        @ds = schema_dataset
        @use_transactions = opts[:use_transactions]
      end

      # The timestamp migrator is current if there are no migrations to apply
      # in either direction.
      def is_current?
        _get_migration_tuples.empty?
      end

      # Apply migration operation
      #
      # @param target [String] the target migration file
      # @param current [String] the current migration version
      #
      # @since x.x.x
      #
      # @see Lotus::Model::Migrator#rollback
      # @see Lotus::Model::Migrator#migrate
      def run(current: nil, target: nil)
        _get_migration_tuples(current: current, target: target).each do |klass, version, direction|
          t = Time.now
          db.log_info("Begin applying migration #{version}, direction: #{direction}")

          _checked_transaction(klass) do
            klass.apply(adapter, direction, logger)
            _update_schema_migrations(version, direction)
          end

          db.log_info("Finished applying migration #{version}, direction: #{direction}, took #{sprintf('%0.6f', Time.now - t)} seconds")
        end
        nil
      end

      # Migrate migrations
      #
      # By default, migrate to latest migration resided in db/migrations
      #
      # @example Migrate to the latest migration
      #   require 'lotus/model/migration'
      #   adapter_cfg = Lotus::Model::Config::Adapter.new(type: :sql, uri: DATABASE_URI)
      #   Lotus::Model::Migrator.new(adapter_cfg).migrate
      #
      # @since x.x.x
      #
      # @see Lotus::Model::Migrator#run
      def migrate
        run
      end

      # Rollback migrations
      #
      # By default, rollback 1 step from all migrations resided in db/migrations
      #
      # @param step [Integer] the step from the last migration that should rollback to (default: 1)
      #
      # @example Rollback to the previous migration
      #   require 'lotus/model'
      #   require 'lotus/model/migration'
      #   require 'lotus/model/migrator'
      #
      #   adapter_cfg = Lotus::Model::Config::Adapter.new(type: :sql, uri: DATABASE_URI)
      #   Lotus::Model::Migrator.new(adapter_cfg).rollback
      #
      # @example Rollback 2 migrations
      #   require 'lotus/model'
      #   require 'lotus/model/migration'
      #   require 'lotus/model/migrator'
      #
      #   adapter_cfg = Lotus::Model::Config::Adapter.new(type: :sql, uri: DATABASE_URI)
      #   Lotus::Model::Migrator.new(adapter_cfg).rollback(step: 2)
      #
      # @example Rollback from custom migration directory
      #   require 'lotus/model'
      #   require 'lotus/model/migration'
      #   require 'lotus/model/migrator'
      #
      #   adapter_cfg = Lotus::Model::Config::Adapter.new(type: :sql, uri: DATABASE_URI)
      #   Lotus::Model::Migrator.new(adapter_cfg).rollback
      #
      # @since x.x.x
      #
      # @see Lotus::Model::Migrator#run
      def rollback(step: 1)
        run(target: _target_version(step), current: current_version)
      end

      # Get the current schema version
      #
      # @since x.x.x
      # @api private
      def current_version
        last_record = ds.last
        last_record ? last_record[column].to_i : 0
      end

      private

      # The DB connection instance
      #
      # @since x.x.x
      # @api private
      attr_reader :db

      # The directory for this migrator's files
      #
      # @since x.x.x
      # @api private
      attr_reader :directory

      # The dataset for this migrator, representing the +schema_migrations+
      #
      # @since x.x.x
      # @api private
      attr_reader :ds

      # The adapter used by this migrator
      #
      # @since x.x.x
      # @api private
      attr_reader :adapter

      # All applied migration files
      #
      # @since x.x.x
      # @api private
      attr_reader :files

      # The logger used by database connection
      #
      # @since x.x.x
      # @api private
      attr_reader :logger

      # Hold the table name of migration table
      #
      # @since x.x.x
      # @api private
      attr_reader :table

      # Hold the column name of migration table
      #
      # @since x.x.x
      # @api private
      attr_reader :column

      # Get the schema version before the current version
      #
      # @since x.x.x
      # @api private
      def _target_version(step)
        record = ds.all[-(1+step)]
        record ? record[column].to_i : 0
      end

      # Remove or update migration version
      #
      # @since x.x.x
      # @api private
      def _update_schema_migrations(version, direction)
        if direction == :up
          _add_to_schema_migrations(version)
        else
          _remove_from_schema_migrarions(version)
        end
      end

      # Add migration version to schema table
      #
      # @since x.x.x
      # @api private
      def _add_to_schema_migrations(version)
        ds.insert(column => version)
      end

      # Remove migration version from schema table
      #
      # @since x.x.x
      # @api private
      def _remove_from_schema_migrarions(version)
        ds.filter(column => version).delete
      end

      # @return [Lotus::Model::Migration::File] applied migration files
      # @since x.x.x
      # @api private
      def _get_applied_migrations
        migrated_versions = _get_migration_versions
        missing_migration_files = []
        applied_migration_files = []

        if migrated_versions.any?
          files.each do |f|
            if migrated_versions.include?(f.version)
              applied_migration_files << f
            else
              missing_migration_files << f
            end
          end

          if missing_migration_files.any? && !@allow_missing_migration_files
            raise MissingMigrationsError.new(missing_migration_files)
          end
        end

        applied_migration_files
      end

      # Return all applied migration versions
      #
      # @since x.x.x
      # @api private
      def _get_migration_versions
        ds.select_order_map(column).map { |v| v.to_i }.sort
      end

      # Returns any migration files found in the migrator's directory
      #
      # @since x.x.x
      # @api private
      def _get_migration_files
        files = []
        Dir.new(directory).each do |file|
          next unless Lotus::Model::Migration::File.migration_file?(file)
          files << Lotus::Model::Migration::File.new(File.join(directory, file))
        end

        _validate_duplicated_versions(files)

        files.sort_by { |f| f.version }
      end

      # Validate if files has any duplicated version
      #
      # @since x.x.x
      # @api private
      def _validate_duplicated_versions(files)
        versions = files.map { |f| f.version }
        duplicated_versions = versions.select { |v| versions.index(v) != versions.rindex(v) }.uniq
        duplicated_version_files = files.select { |f| duplicated_versions.include?(f.version) }.group_by { |f| f.version }

        if duplicated_versions.any?
          message = ['Duplicated versions in following migrations:']
          duplicated_version_files.each do |vesrion, files|
            message << "  * #{files.map { |f| f.path }.join(', ')}"
          end
          message = message.join("\n")

          raise DuplicatedVersionsError.new(message)
        end
      end

      # Returns tuples of migration class, version, and direction
      #
      # @since x.x.x
      # @api private
      def _get_migration_tuples(current: nil, target: nil)
        _remove_migration_classes
        up_mts = []
        down_mts = []
        ms = ::Lotus::Model::Migration.descendants
        applied_migrations = _get_applied_migrations

        files.each do |file|
          path = file.path
          version = file.version
          if target
            if version > target
              if applied_migrations.include?(file)
                load(path)
                down_mts << [ms.last, version, :down]
              end
            elsif !applied_migrations.include?(file)
              load(path)
              up_mts << [ms.last, version, :up]
            end
          elsif !applied_migrations.include?(file)
            load(path)
            up_mts << [ms.last, version, :up]
          end
        end
        up_mts + down_mts.reverse
      end

      # Returns the dataset for the schema_migrations table. If no such table
      # exists, it is automatically created.
      #
      # @since x.x.x
      # @api private
      def schema_dataset
        c = column
        ds = db.from(table).order(column)

        if !db.table_exists?(table)
          db.create_table(table) { String c, primary_key: true }
        elsif !ds.columns.include?(c)
          raise(Error, "Migrator table #{table} does not contain column #{c}")
        end
        ds
      end

      # If transactions should be used for the migration, yield to the block
      # inside a transaction.  Otherwise, just yield to the block.
      #
      # @since x.x.x
      # @api private
      def _checked_transaction(migration, &block)
        use_trans = if @use_transactions.nil?
                      if migration.use_transactions.nil?
                        @db.supports_transactional_ddl?
                      else
                        migration.use_transactions
                      end
                    else
                      @use_transactions
                    end

        if use_trans
          db.transaction(&block)
        else
          yield
        end
      end

      # Remove all migration classes.  Done by the migrator to ensure that
      # the correct migration classes are picked up.
      #
      # @since x.x.x
      # @api private
      def _remove_migration_classes
        # Remove class definitions
        ::Lotus::Model::Migration.descendants.each do |c|
          Object.send(:remove_const, c.to_s) rescue nil
        end
        ::Lotus::Model::Migration.descendants.clear # remove any defined migration classes
      end

      # The framework configuration
      # It is copied from the framework configuration in constructor
      #
      # @api private
      def configuration
        self.class.configuration
      end

      # Copy framework configuration
      #
      # @since x.x.x
      # @api private
      def _copy_framework_configuration
        config = Lotus::Model::Configuration.for(self.class)
        self.class.configuration = config
      end

      # Return the adapter configuration
      #
      # @since x.x.x
      # @api private
      def _adapter_config
        configuration.adapter_config
      end

      # Check to ensure adapter is configured
      #
      # @since x.x.x
      # @api private
      def _check_if_adapter_is_configured
        raise MissingAdapterConfigurationError unless _adapter_config
      end

      # Check if adapter supports migration
      #
      # @since x.x.x
      # @api private
      def _check_if_adapter_support_migration
        adapter_type = _adapter_config.type

        unless SUPPORTED_ADAPTERS.include?(adapter_type)
          raise UnsupportedAdapterError.new(adapter_type)
        end
      end

      # Instantiate adapter
      #
      # @since x.x.x
      # @api private
      def _get_adapter
        self.class.configuration.build_adapter
        self.class.configuration.instance_variable_get(:@adapter)
      end

      # Return the logger from framework configuration
      #
      # @since x.x.x
      # @api private
      def _get_logger
        configuration.logger
      end

      # Get the migration directory
      #
      # @since x.x.x
      # @api private
      def _get_migrations_directory
        directory = configuration.migrations_directory
        raise(Error, "Must supply a valid migration path") unless File.directory?(directory)
        directory
      end
    end
  end
end
