require 'sequel'

module Lotus
  module Model
    module Adapters
      module Sql
        # Allow users to easily group schema changes and migrate the
        # database to a newer version or revert to a previous version.
        #
        # A migration class must be subclass of Lotus::Model::Migration
        # and must have 2 instance methods:
        #
        #   * up   - to migrate
        #   * down - to rollback
        #
        # Both instance methods could access following schema modification methods:
        #
        #   * add_column
        #   * add_index
        #   * create_view
        #   * drop_column
        #   * drop_index
        #   * drop_table
        #   * drop_view
        #   * rename_table
        #   * rename_column
        #   * set_column_default
        #   * set_column_type
        #
        # For more details, please consult documentation
        # at http://sequel.jeremyevans.net/rdoc/files/doc/schema_modification_rdoc.html
        #
        # To apply up/down migration, please consult Lotus::Model::Migration#run
        # Please avoid running running migration through the low level
        # Sequel API because doing so does not update the schema_versions table
        # and thus will create inconsistency in migration history.
        #
        # Due to the fact the Sequel is going to kill old class based migration,
        # it is decided to clone source code from Sequel::Migration.
        #
        # @example Create and apply migration
        #   require 'lotus/model/migration'
        #
        #   class MyMigration < Lotus::Model::Migration
        #     def up
        #       create_table(:authors) do
        #         primary_key :id
        #         String :name
        #       end
        #     end
        #
        #     def down
        #       drop_table(:authors)
        #     end
        #   end
        #
        #   # to apply up migration
        #   MyMigration.new(adapter).up
        #
        #   # to apply down migration
        #   MyMigration.new(adapter).down
        #
        # @since x.x.x
        # @api private
        class SchemaModifier
          def initialize(adapter, logger = nil)
            @connection = adapter.connection
            @connection.logger = logger if logger
          end

          private

          # Intercepts method calls intended for the database and sends them along.
          #
          # @since x.x.x
          # @api private
          def method_missing(method_sym, *args, &block)
            connection.send(method_sym, *args, &block)
          end

          # This object responds to all methods the database responds to.
          #
          # @since x.x.x
          # @api private
          def respond_to_missing?(meth, include_private)
            connection.respond_to?(meth, include_private)
          end

          # The DB Connection
          #
          # @since x.x.x
          # @api private
          attr_reader :connection

        end
      end
    end
  end
end
