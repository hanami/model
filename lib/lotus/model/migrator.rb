require 'sequel'
require 'sequel/extensions/migration'
require 'lotus/model/migrator/connection'
require 'lotus/model/migrator/adapter'

module Lotus
  module Model
    # Migration error
    #
    # @since 0.4.0
    class MigrationError < ::StandardError
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
    #   Lotus::Model.migration do
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
    #   Lotus::Model.migration do
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
      # @raise [Lotus::Model::MigrationError] if an error occurs
      #
      # @since 0.4.0
      #
      # @see Lotus::Model::Configuration#adapter
      #
      # @example
      #   require 'lotus/model'
      #   require 'lotus/model/migrator'
      #
      #   Lotus::Model.configure do
      #     # ...
      #     adapter type: :sql, uri: 'postgres://localhost/foo'
      #   end
      #
      #   Lotus::Model::Migrator.create # Creates `foo' database
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
      # @raise [Lotus::Model::MigrationError] if an error occurs
      #
      # @since 0.4.0
      #
      # @see Lotus::Model::Configuration#adapter
      #
      # @example
      #   require 'lotus/model'
      #   require 'lotus/model/migrator'
      #
      #   Lotus::Model.configure do
      #     # ...
      #     adapter type: :sql, uri: 'postgres://localhost/foo'
      #   end
      #
      #   Lotus::Model::Migrator.drop # Drops `foo' database
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
      # @raise [Lotus::Model::MigrationError] if an error occurs
      #
      # @since 0.4.0
      #
      # @see Lotus::Model::Configuration#adapter
      # @see Lotus::Model::Configuration#migrations
      #
      # @example Migrate Up
      #   require 'lotus/model'
      #   require 'lotus/model/migrator'
      #
      #   Lotus::Model.configure do
      #     # ...
      #     adapter    type: :sql, uri: 'postgres://localhost/foo'
      #     migrations 'db/migrations'
      #   end
      #
      #   # Reads all files from "db/migrations" and apply them
      #   Lotus::Model::Migrator.migrate
      #
      # @example Migrate Down
      #   require 'lotus/model'
      #   require 'lotus/model/migrator'
      #
      #   Lotus::Model.configure do
      #     # ...
      #     adapter    type: :sql, uri: 'postgres://localhost/foo'
      #     migrations 'db/migrations'
      #   end
      #
      #   # Reads all files from "db/migrations" and apply them
      #   Lotus::Model::Migrator.migrate
      #
      #   # Migrate to a specifiy version
      #   Lotus::Model::Migrator.migrate(version: "20150610133853")
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
      # @raise [Lotus::Model::MigrationError] if an error occurs
      #
      # @since 0.4.0
      #
      # @see Lotus::Model::Configuration#adapter
      # @see Lotus::Model::Configuration#migrations
      #
      # @example Apply Migrations
      #   require 'lotus/model'
      #   require 'lotus/model/migrator'
      #
      #   Lotus::Model.configure do
      #     # ...
      #     adapter    type: :sql, uri: 'postgres://localhost/foo'
      #     migrations 'db/migrations'
      #     schema     'db/schema.sql'
      #   end
      #
      #   # Reads all files from "db/migrations" and apply and delete them.
      #   # It generates an updated version of "db/schema.sql"
      #   Lotus::Model::Migrator.apply
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
      # @raise [Lotus::Model::MigrationError] if an error occurs
      #
      # @since 0.4.0
      #
      # @see Lotus::Model::Migrator.apply
      #
      # @example Prepare Database
      #   require 'lotus/model'
      #   require 'lotus/model/migrator'
      #
      #   Lotus::Model.configure do
      #     # ...
      #     adapter    type: :sql, uri: 'postgres://localhost/foo'
      #     migrations 'db/migrations'
      #   end
      #
      #   Lotus::Model::Migrator.prepare # => creates `foo' and run migrations
      #
      # @example Prepare Database (with schema dump)
      #   require 'lotus/model'
      #   require 'lotus/model/migrator'
      #
      #   Lotus::Model.configure do
      #     # ...
      #     adapter    type: :sql, uri: 'postgres://localhost/foo'
      #     migrations 'db/migrations'
      #     schema     'db/schema.sql'
      #   end
      #
      #   Lotus::Model::Migrator.apply   # => updates schema dump
      #   Lotus::Model::Migrator.prepare # => creates `foo', load schema and run pending migrations (if any)
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
      #   Lotus::Model::Migrator.version # => "20150610133853"
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
      end

      # Lotus::Model configuration
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
        migrations.children.reject { |file| file.basename.to_s.start_with?('.') }.any?
      end
    end
  end
end
