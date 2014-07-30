require 'lotus/utils/class'

module Lotus
  module Model
    module Config
      # Raised when an adapter class does not exist
      #
      # @since x.x.x
      class AdapterNotFound < ::StandardError
      end

      # Configuration for the adapter
      #
      # Lotus::Model has its own global configuration that can be manipulated
      # via `Lotus::Model.configure`.
      #
      # New adapter configuration can be registered via `Lotus::Model.adapter`.
      #
      # @see Lotus::Model.adapter
      #
      # @example
      #   require 'lotus/model'
      #
      #   Lotus::Model.configure do
      #     adapter :sql, 'postgres://localhost/database'
      #   end
      #
      # Registered adapters can be retrieved via `Lotus::Model.adapters`
      #
      # @see Lotus::Model.adapters
      #
      # @example
      #   Lotus::Model.adapter[:sql]
      #   # => Lotus::Model::Config::Adapter(name: :sql, uri: 'postgres://localhost/database')
      #
      # @since 0.2.0
      class Adapter
        # @return name [Symbol] the unique adapter name
        #
        # @since 0.2.0
        #
        # @see Lotus::Config::Adapter#name
        attr_reader :name

        # @return uri [String] the adapter URI
        #
        # @since 0.2.0
        #
        # @see Lotus::Config::Adapter#uri
        attr_reader :uri

        # Initialize an adapter configuration instance
        #
        # @return [Lotus::Model::Config::Adapter] a new apdapter configuration's
        #   instance
        #
        # @since 0.2.0
        def initialize(name, uri = nil)
          @name, @uri, @default = name, uri
        end

        # Initialize the adapter
        #
        # @param name [Lotus::Model::Mapper] the mapper instance
        #
        # @return [Lotus::Model::Adapters::SqlAdapter, Lotus::Model::Adapters::MemoryAdapter] an adapter instance
        #
        # @see Lotus::Model::Adapters
        #
        # @since x.x.x
        def load!(mapper)
          adapter_class.new(mapper, uri)
        end

        private

        def adapter_class
          klass_name = Lotus::Utils::String.new("#{name}_adapter").classify
          begin
            Lotus::Utils::Class.load!(klass_name, Lotus::Model::Adapters)
          rescue
            raise AdapterNotFound
          end
        end
      end
    end
  end
end
