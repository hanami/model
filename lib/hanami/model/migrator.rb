require 'sequel'
require 'sequel/extensions/migration'
require 'hanami/model/migrator/connection'
require 'hanami/model/migrator/adapter'

module Hanami
  module Model
    # Migration error
    #
    # @since 0.4.0
    class MigrationError < Hanami::Model::Error
    end

    # Define a migration
    #
    # It must define an up/down strategy to write schema changes (up) and to
    # rollback them (down).
    #
    # We can use <tt>up</tt> and <tt>down</tt> blocks for custom strategies, or
    # only one <tt>change</tt> block that automatically implements "down" strategy.
    #
    # @param blk [Proc] a block that defines up/down or change database migration
    #
    # @since 0.4.0
    #
    # @example Use up/down blocks
    #   Hanami::Model.migration do
    #     up do
    #       create_table :books do
    #         primary_key :id
    #         column :book, String
    #       end
    #     end
    #
    #     down do
    #       drop_table :books
    #     end
    #   end
    #
    # @example Use change block
    #   Hanami::Model.migration do
    #     change do
    #       create_table :books do
    #         primary_key :id
    #         column :book, String
    #       end
    #     end
    #
    #     # DOWN strategy is automatically generated
    #   end
    def self.migration(&blk)
      Sequel.migration(&blk)
    end

    # Database schema migrator
    #
    # @since 0.4.0
    module Migrator
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
      #     adapter type: :sql, uri: 'postgres://localhost/foo'
      #   end
      #
      #   Hanami::Model::Migrator.create # Creates `foo' database
      def self.create
        adapter(connection).create
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
      #     adapter type: :sql, uri: 'postgres://localhost/foo'
      #   end
      #
      #   Hanami::Model::Migrator.drop # Drops `foo' database
      def self.drop
        adapter(connection).drop
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
      #
      # @example Migrate Up
      #   require 'hanami/model'
      #   require 'hanami/model/migrator'
      #
      #   Hanami::Model.configure do
      #     # ...
      #     adapter    type: :sql, uri: 'postgres://localhost/foo'
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
      #     adapter    type: :sql, uri: 'postgres://localhost/foo'
      #     migrations 'db/migrations'
      #   end
      #
      #   # Reads all files from "db/migrations" and apply them
      #   Hanami::Model::Migrator.migrate
      #
      #   # Migrate to a specifiy version
      #   Hanami::Model::Migrator.migrate(version: "20150610133853")
      def self.migrate(version: nil)
        version = Integer(version) unless version.nil?

        Sequel::Migrator.run(connection, migrations, target: version, allow_missing_migration_files: true) if migrations?
      rescue Sequel::Migrator::Error => e
        raise MigrationError.new(e.message)
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
      #     adapter    type: :sql, uri: 'postgres://localhost/foo'
      #     migrations 'db/migrations'
      #     schema     'db/schema.sql'
      #   end
      #
      #   # Reads all files from "db/migrations" and apply and delete them.
      #   # It generates an updated version of "db/schema.sql"
      #   Hanami::Model::Migrator.apply
      def self.apply
        migrate
        adapter(connection).dump
        delete_migrations
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
      #     adapter    type: :sql, uri: 'postgres://localhost/foo'
      #     migrations 'db/migrations'
      #   end
      #
      #   Hanami::Model::Migrator.prepare # => creates `foo' and run migrations
      #
      # @example Prepare Database (with schema dump)
      #   require 'hanami/model'
      #   require 'hanami/model/migrator'
      #
      #   Hanami::Model.configure do
      #     # ...
      #     adapter    type: :sql, uri: 'postgres://localhost/foo'
      #     migrations 'db/migrations'
      #     schema     'db/schema.sql'
      #   end
      #
      #   Hanami::Model::Migrator.apply   # => updates schema dump
      #   Hanami::Model::Migrator.prepare # => creates `foo', load schema and run pending migrations (if any)
      def self.prepare
        drop rescue nil
        create
        adapter(connection).load
        migrate
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
      def self.version
        adapter(connection).version
      end

      private

      # Loads an adapter for the given connection
      #
      # @since 0.4.0
      # @api private
      def self.adapter(connection)
        Adapter.for(connection)
      end

      # Delete all the migrations
      #
      # @since 0.4.0
      # @api private
      def self.delete_migrations
        migrations.each_child(&:delete)
      end

      # Database connection
      #
      # @since 0.4.0
      # @api private
      def self.connection
        Sequel.connect(
          configuration.adapter.uri
        )
      rescue Sequel::AdapterNotFound
        raise MigrationError.new("Current adapter (#{ configuration.adapter.type }) doesn't support SQL database operations.")
      end

      # Hanami::Model configuration
      #
      # @since 0.4.0
      # @api private
      def self.configuration
        Model.configuration
      end

      # Migrations directory
      #
      # @since 0.4.0
      # @api private
      def self.migrations
        configuration.migrations
      end

      # Check if there are migrations
      #
      # @since 0.4.0
      # @api private
      def self.migrations?
        Dir["#{ migrations }/*.rb"].any?
      end
    end
  end
end
