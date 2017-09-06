require 'rom-sql'
require 'hanami/utils'

module Hanami
  # Hanami::Model migrations
  module Model
    require 'hanami/model/error'
    require 'hanami/model/association'
    require 'hanami/model/migration'

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
      Migration.new(configuration.gateways[:default], &blk)
    end

    # SQL adapter
    #
    # @since 0.7.0
    module Sql
      require 'hanami/model/sql/types'
      require 'hanami/model/sql/entity/schema'

      # Returns a SQL fragment that references a database function by the given name
      # This is useful for database migrations
      #
      # @param name [String,Symbol] the function name
      # @return [String] the SQL fragment
      #
      # @since 0.7.0
      #
      # @example
      #   Hanami::Model.migration do
      #     up do
      #       execute 'CREATE EXTENSION IF NOT EXISTS "uuid-ossp"'
      #
      #       create_table :source_files do
      #         column :id, 'uuid', primary_key: true, default: Hanami::Model::Sql.function(:uuid_generate_v4)
      #         # ...
      #       end
      #     end
      #
      #     down do
      #       drop_table :source_files
      #       execute 'DROP EXTENSION "uuid-ossp"'
      #     end
      #   end
      def self.function(name)
        Sequel.function(name)
      end

      # Returns a literal SQL fragment for the given SQL fragment.
      # This is useful for database migrations
      #
      # @param string [String] the SQL fragment
      # @return [String] the literal SQL fragment
      #
      # @since 0.7.0
      #
      # @example
      #   Hanami::Model.migration do
      #     up do
      #       execute %{
      #         CREATE TYPE inventory_item AS (
      #           name            text,
      #           supplier_id     integer,
      #           price           numeric
      #         );
      #       }
      #
      #       create_table :items do
      #         column :item, 'inventory_item', default: Hanami::Model::Sql.literal("ROW('fuzzy dice', 42, 1.99)")
      #         # ...
      #       end
      #     end
      #
      #     down do
      #       drop_table :items
      #       execute 'DROP TYPE inventory_item'
      #     end
      #   end
      def self.literal(string)
        Sequel.lit(string)
      end

      # Returns SQL fragment for ascending order for the given column
      #
      # @param column [Symbol] the column name
      # @return [String] the SQL fragment
      #
      # @since 0.7.0
      def self.asc(column)
        Sequel.asc(column)
      end

      # Returns SQL fragment for descending order for the given column
      #
      # @param column [Symbol] the column name
      # @return [String] the SQL fragment
      #
      # @since 0.7.0
      def self.desc(column)
        Sequel.desc(column)
      end
    end

    Error.register(ROM::SQL::DatabaseError,             DatabaseError)
    Error.register(ROM::SQL::ConstraintError,           ConstraintViolationError)
    Error.register(ROM::SQL::NotNullConstraintError,    NotNullConstraintViolationError)
    Error.register(ROM::SQL::UniqueConstraintError,     UniqueConstraintViolationError)
    Error.register(ROM::SQL::CheckConstraintError,      CheckConstraintViolationError)
    Error.register(ROM::SQL::ForeignKeyConstraintError, ForeignKeyConstraintViolationError)
    Error.register(ROM::SQL::UnknownDBTypeError,        UnknownDatabaseTypeError)
    Error.register(ROM::SQL::MissingPrimaryKeyError,    MissingPrimaryKeyError)

    Error.register(Java::JavaSql::SQLException, DatabaseError) if Utils.jruby?
  end
end

Sequel.default_timezone = :utc

ROM.plugins do
  adapter :sql do
    register :mapping,    Hanami::Model::Plugins::Mapping,    type: :command
    register :schema,     Hanami::Model::Plugins::Schema,     type: :command
    register :timestamps, Hanami::Model::Plugins::Timestamps, type: :command
  end
end
