module Hanami
  module Model
    # Database migration
    #
    # @since 0.7.0
    # @api private
    class Migration
      # @since 0.7.0
      # @api private
      attr_reader :gateway

      # @since 0.7.0
      # @api private
      attr_reader :migration

      # @since 0.7.0
      # @api private
      def initialize(gateway, &block)
        @gateway = gateway
        @migration = gateway.migration(&block)
        freeze
      end

      # @since 0.7.0
      # @api private
      def run(direction = :up)
        migration.apply(gateway.connection, direction)
      end
    end
  end
end
