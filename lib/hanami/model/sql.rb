require 'rom-sql'

module Hanami
  module Model
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

    module Sql
      def self.function(name)
        Sequel.function(name)
      end

      def self.literal(string)
        Sequel.lit(string)
      end
    end
  end
end

Sequel.default_timezone = :utc

ROM.plugins do
  adapter :sql do
    register :mapping,    Hanami::Model::Plugins::Mapping,    type: :command
    register :timestamps, Hanami::Model::Plugins::Timestamps, type: :command
  end
end
