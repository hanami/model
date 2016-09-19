module Hanami
  module Model
    # Database migration
    #
    # @since x.x.x
    # @api private
    class Migration
      # @since x.x.x
      # @api private
      attr_reader :gateway

      # @since x.x.x
      # @api private
      attr_reader :migration

      # @since x.x.x
      # @api private
      def initialize(gateway, &block)
        @gateway = gateway
        @migration = gateway.migration(&block)
        freeze
      end

      # @since x.x.x
      # @api private
      def run(direction = :up)
        migration.apply(gateway.connection, direction)
      end
    end
  end
end
