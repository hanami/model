module Lotus
  module Model
    # Configuration for the framework, models and adapters.
    #
    # Lotus::Model has its own global configuration that can be manipulated
    # via `Lotus::Model.configure`.
    #
    # @since 0.2.0
    class Configuration

      # @attr_accessor adapters [Hash] a hash of Lotus::Model::Config::Adapter
      #
      # @since 0.2.0
      #
      # @see Lotus::Controller::Configuration#adapters
      attr_accessor :adapters

      # Initialize a configuration instance
      #
      # @return [Lotus::Model::Configuration] a new configuration's
      #   instance
      #
      # @since 0.2.0
      def initialize
        @adapters = {}
      end

      # Reset all the values to the defaults
      #
      # @since 0.2.0
      # @api private
      def reset!
        @adapters = {}
      end
    end
  end
end
