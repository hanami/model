require 'delegate'
require 'lotus/utils/class_attribute'
require 'lotus/model/adapters/sql/schema_modifier'

module Lotus
  module Model
    # Allow users to easily group schema changes and migrate the
    # database to a newer version or revert to a previous version.
    #
    # A migration class must be subclass of Lotus::Model::Migration
    # and must implement 2 instance methods:
    #
    #   * up   - to migrate
    #   * down - to rollback
    #
    # Both instance methods could access following schema modification methods.
    # Please consult +Lotus::Model::Adapters::Sql::SchemaModifier+ for more details.
    #
    # To apply up/down migration, please consult +Lotus::Model::Migration.apply+
    # though it is not recommended to apply migration directly without going
    # through the +Lotus::Model::Migrator#run+. Because Migrator will retain
    # the history of applied migrations.
    #
    # The implementation is based on top of old Sequel::Migration.
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
    # @see Lotus::Model::Adapters::Sql::SchemaModifier
    # @api private
    class Migration < SimpleDelegator
      # Delegate all schema modification methods to +Lotus::Model::Adapters::Sql::SchemaModifier+
      #
      # @param [Lotus::Model::Adapters::SqlAdapter] instance of SQL adapter
      # @param [Logger] instance of logger for adapter connection
      #
      # @since x.x.x
      def initialize(adapter, logger = nil)
        @schema_modifier = Lotus::Model::Adapters::Sql::SchemaModifier.new(adapter, logger)
        super(@schema_modifier)
      end

      class << self
        # Applies the migration to the supplied database in the specified
        # direction.
        #
        # @param [Lotus::Model::Adapters::SqlAdapter] instance of SQL adapter
        # @param [Logger] instance of logger for adapter connection
        # @param [Symbol] direction, either :up or :down
        #
        # @since x.x.x
        def apply(adapter, direction, logger = nil)
          _validate_direction(direction)
          new(adapter, logger).send(direction)
        end

        # Don't allow transaction overriding in old migrations.
        def use_transactions
          nil
        end

        private

        # Validate the direction
        #
        # @since x.x.x
        # @api private
        def _validate_direction(direction)
          raise(ArgumentError, "Invalid migration direction specified (#{direction.inspect})") unless [:up, :down].include?(direction)
        end
      end

      include Utils::ClassAttribute

      # It's used to store all subclasses of Migration
      #
      # @since x.x.x
      # @api private
      class_attribute :descendants
      self.descendants ||= []

      # Adds the new migration class to the list of Migration descendants.
      #
      # @since x.x.x
      # @see Lotus::Model::Migration.descendants
      def self.inherited(base)
        descendants << base
      end

      # The default up action does nothing
      # It's supposed to be overriden by subclass
      #
      # @since x.x.x
      def up
        raise NotImplementedError.new("Please override this method in migration subclass")
      end

      # The default down action does nothing
      # It's supposed to be overriden by subclass
      #
      # @since x.x.x
      def down
        raise NotImplementedError.new("Please override this method in migration subclass")
      end

    end
  end
end
