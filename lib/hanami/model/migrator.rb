require 'sequel'
require 'sequel/extensions/migration'

module Hanami
  module Model
    # Migration error
    #
    # @since 0.4.0
    class MigrationError < Hanami::Model::Error
    end

    # Database schema migrator
    #
    # @since 0.4.0
    class Migrator
      require 'hanami/model/migrator/connection'
      require 'hanami/model/migrator/adapter'

      # Create database defined by current configuration.
      #
      # It's only implemented for the following databases:
      #
      #   * SQLite3
      #   * PostgreSQL
      #   * MySQL
      #
      # @raise [Hanami::Model::MigrationError] if an error occurs
      #
      # @since 0.4.0
      #
      # @see Hanami::Model::Configuration#adapter
      #
      # @example
      #   require 'hanami/model'
      #   require 'hanami/model/migrator'
      #
      #   Hanami::Model.configure do
      #     # ...
      #     adapter :sql, 'postgres://localhost/foo'
      #   end
      #
      #   Hanami::Model::Migrator.create # Creates `foo' database
      #
      # NOTE: Class level interface SHOULD be removed in Hanami 2.0
      def self.create
        new.create
      end

      # Drop database defined by current configuration.
      #
      # It's only implemented for the following databases:
      #
      #   * SQLite3
      #   * PostgreSQL
      #   * MySQL
      #
      # @raise [Hanami::Model::MigrationError] if an error occurs
      #
      # @since 0.4.0
      #
      # @see Hanami::Model::Configuration#adapter
      #
      # @example
      #   require 'hanami/model'
      #   require 'hanami/model/migrator'
      #
      #   Hanami::Model.configure do
      #     # ...
      #     adapter :sql, 'postgres://localhost/foo'
      #   end
      #
      #   Hanami::Model::Migrator.drop # Drops `foo' database
      #
      # NOTE: Class level interface SHOULD be removed in Hanami 2.0
      def self.drop
        new.drop
      end

      # Migrate database schema
      #
      # It's possible to migrate "down" by specifying a version
      # (eg. <tt>"20150610133853"</tt>)
      #
      # @param version [String,NilClass] target version
      #
      # @raise [Hanami::Model::MigrationError] if an error occurs
      #
      # @since 0.4.0
      #
      # @see Hanami::Model::Configuration#adapter
      # @see Hanami::Model::Configuration#migrations
      # @see Hanami::Model::Configuration#rollback
      #
      # @example Migrate Up
      #   require 'hanami/model'
      #   require 'hanami/model/migrator'
      #
      #   Hanami::Model.configure do
      #     # ...
      #     adapter    :sql, 'postgres://localhost/foo'
      #     migrations 'db/migrations'
      #   end
      #
      #   # Reads all files from "db/migrations" and apply them
      #   Hanami::Model::Migrator.migrate
      #
      # @example Migrate Down
      #   require 'hanami/model'
      #   require 'hanami/model/migrator'
      #
      #   Hanami::Model.configure do
      #     # ...
      #     adapter    :sql, 'postgres://localhost/foo'
      #     migrations 'db/migrations'
      #   end
      #
      #   # Reads all files from "db/migrations" and apply them
      #   Hanami::Model::Migrator.migrate
      #
      #   # Migrate to a specific version
      #   Hanami::Model::Migrator.migrate(version: "20150610133853")
      #
      # NOTE: Class level interface SHOULD be removed in Hanami 2.0
      def self.migrate(version: nil)
        new.migrate(version: version)
      end

      # Rollback database schema
      #
      # @param steps [Number,NilClass] number of versions to rollback
      #
      # @raise [Hanami::Model::MigrationError] if an error occurs
      #
      # @since 1.1.0
      #
      # @see Hanami::Model::Configuration#adapter
      # @see Hanami::Model::Configuration#migrations
      # @see Hanami::Model::Configuration#migrate
      #
      # @example Rollback
      #   require 'hanami/model'
      #   require 'hanami/model/migrator'
      #
      #   Hanami::Model.configure do
      #     # ...
      #     adapter    :sql, 'postgres://localhost/foo'
      #     migrations 'db/migrations'
      #   end
      #
      #   # Reads all files from "db/migrations" and apply them
      #   Hanami::Model::Migrator.migrate
      #
      #   # By default only rollback one version
      #   Hanami::Model::Migrator.rollback
      #
      #   # Use a hash passing a number of versions to rollback, it will rollbacks those versions
      #   Hanami::Model::Migrator.rollback(versions: 2)
      #
      # NOTE: Class level interface SHOULD be removed in Hanami 2.0
      def self.rollback(steps: 1)
        new.rollback(steps: steps)
      end

      # Migrate, dump schema, delete migrations.
      #
      # This is an experimental feature.
      # It may change or be removed in the future.
      #
      # Actively developed applications accumulate tons of migrations.
      # In the long term they are hard to maintain and slow to execute.
      #
      # "Apply" feature solves this problem.
      #
      # It keeps an updated SQL file with the structure of the database.
      # This file can be used to create fresh databases for developer machines
      # or during testing. This is faster than to run dozen or hundred migrations.
      #
      # When we use "apply", it eliminates all the migrations that are no longer
      # necessary.
      #
      # @raise [Hanami::Model::MigrationError] if an error occurs
      #
      # @since 0.4.0
      #
      # @see Hanami::Model::Configuration#adapter
      # @see Hanami::Model::Configuration#migrations
      #
      # @example Apply Migrations
      #   require 'hanami/model'
      #   require 'hanami/model/migrator'
      #
      #   Hanami::Model.configure do
      #     # ...
      #     adapter    :sql, 'postgres://localhost/foo'
      #     migrations 'db/migrations'
      #     schema     'db/schema.sql'
      #   end
      #
      #   # Reads all files from "db/migrations" and apply and delete them.
      #   # It generates an updated version of "db/schema.sql"
      #   Hanami::Model::Migrator.apply
      #
      # NOTE: Class level interface SHOULD be removed in Hanami 2.0
      def self.apply
        new.apply
      end

      # Prepare database: drop, create, load schema (if any), migrate.
      #
      # This is designed for development machines and testing mode.
      # It works faster if used with <tt>apply</tt>.
      #
      # @raise [Hanami::Model::MigrationError] if an error occurs
      #
      # @since 0.4.0
      #
      # @see Hanami::Model::Migrator.apply
      #
      # @example Prepare Database
      #   require 'hanami/model'
      #   require 'hanami/model/migrator'
      #
      #   Hanami::Model.configure do
      #     # ...
      #     adapter    :sql, 'postgres://localhost/foo'
      #     migrations 'db/migrations'
      #   end
      #
      #   Hanami::Model::Migrator.prepare # => creates `foo' and runs migrations
      #
      # @example Prepare Database (with schema dump)
      #   require 'hanami/model'
      #   require 'hanami/model/migrator'
      #
      #   Hanami::Model.configure do
      #     # ...
      #     adapter    :sql, 'postgres://localhost/foo'
      #     migrations 'db/migrations'
      #     schema     'db/schema.sql'
      #   end
      #
      #   Hanami::Model::Migrator.apply   # => updates schema dump
      #   Hanami::Model::Migrator.prepare # => creates `foo', load schema and run pending migrations (if any)
      #
      # NOTE: Class level interface SHOULD be removed in Hanami 2.0
      def self.prepare
        new.prepare
      end

      # Return current database version timestamp
      #
      # If no migrations were ran, it returns <tt>nil</tt>.
      #
      # @return [String,NilClass] current version, if previously migrated
      #
      # @since 0.4.0
      #
      # @example
      #   # Given last migrations is:
      #   #  20150610133853_create_books.rb
      #
      #   Hanami::Model::Migrator.version # => "20150610133853"
      #
      # NOTE: Class level interface SHOULD be removed in Hanami 2.0
      def self.version
        new.version
      end

      # Instantiate a new migrator
      #
      # @param configuration [Hanami::Model::Configuration] framework configuration
      #
      # @return [Hanami::Model::Migrator] a new instance
      #
      # @since 0.7.0
      # @api private
      def initialize(configuration: self.class.configuration)
        @configuration = configuration
        @adapter       = Adapter.for(configuration)
      end

      # @since 0.7.0
      # @api private
      #
      # @see Hanami::Model::Migrator.create
      def create
        adapter.create
      end

      # @since 0.7.0
      # @api private
      #
      # @see Hanami::Model::Migrator.drop
      def drop
        adapter.drop
      end

      # @since 0.7.0
      # @api private
      #
      # @see Hanami::Model::Migrator.migrate
      def migrate(version: nil)
        adapter.migrate(migrations, version) if migrations?
      end

      # @since 1.1.0
      # @api private
      #
      # @see Hanami::Model::Migrator.rollback
      def rollback(steps: 1)
        adapter.rollback(migrations, steps.abs) if migrations?
      end

      # @since 0.7.0
      # @api private
      #
      # @see Hanami::Model::Migrator.apply
      def apply
        migrate
        adapter.dump
        delete_migrations
      end

      # @since 0.7.0
      # @api private
      #
      # @see Hanami::Model::Migrator.prepare
      def prepare
        drop
      rescue # rubocop:disable Lint/HandleExceptions
      ensure
        create
        adapter.load
        migrate
      end

      # @since 0.7.0
      # @api private
      #
      # @see Hanami::Model::Migrator.version
      def version
        adapter.version
      end

      # Hanami::Model configuration
      #
      # @since 0.4.0
      # @api private
      def self.configuration
        Model.configuration
      end

      private

      # @since 0.7.0
      # @api private
      attr_reader :configuration

      # @since 0.7.0
      # @api private
      attr_reader :connection

      # @since 0.7.0
      # @api private
      attr_reader :adapter

      # Migrations directory
      #
      # @since 0.7.0
      # @api private
      def migrations
        configuration.migrations
      end

      # Check if there are migrations
      #
      # @since 0.7.0
      # @api private
      def migrations?
        Dir["#{migrations}/*.rb"].any?
      end

      # Delete all the migrations
      #
      # @since 0.7.0
      # @api private
      def delete_migrations
        migrations.each_child(&:delete)
      end
    end
  end
end
