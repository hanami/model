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
      # By convention, Lotus inflects adapter name to find the adapter class
      # For example, if adapter name is :sql, derived class will be `Lotus::Model::Adapters::SqlAdapter`
      #
      # Custom adapter class can be configured via `class_name` option
      #
      # @example
      #   require 'lotus/model'
      #
      #   Lotus::Model.configure do
      #     adapter :sql, 'postgres://localhost/database', class_name: 'UberSqlAdapter'
      #   end
      #
      # which would load `Lotus::Model::Adapters::UberSqlAdapter`
      #
      #
      # Registered adapters can be retrieved via `Lotus::Model.adapters`
      #
      # @see Lotus::Model.adapters
      #
      # @example
      #   Lotus::Model.adapter[:sql]
      #   # => Lotus::Model::Config::Adapter(name: :sql, uri: 'postgres://localhost/database')
      #
      # @since x.x.x
      class Adapter
        # @return name [Symbol] the unique adapter name
        #
        # @since x.x.x
        attr_reader :name

        # @return uri [String] the adapter URI
        #
        # @since x.x.x
        attr_reader :uri

        # @return uri [String] the adapter class name
        #
        # @since x.x.x
        attr_reader :class_name

        # Initialize an adapter configuration instance
        #
        # @param name [Symbol] adapter config name
        # @param uri  [String] adapter URI
        # @param class_name [String] adapter class name
        #
        # @return [Lotus::Model::Config::Adapter] a new apdapter configuration's
        #   instance
        #
        # @since x.x.x
        def initialize(name, uri = nil, class_name = nil)
          @name, @uri, @class_name = name, uri, class_name
        end

        # Initialize the adapter
        #
        # @param mapper [Lotus::Model::Mapper] the mapper instance
        #
        # @return [Lotus::Model::Adapters::SqlAdapter, Lotus::Model::Adapters::MemoryAdapter] an adapter instance
        #
        # @see Lotus::Model::Adapters
        #
        # @since x.x.x
        def build(mapper)
          load_dependency
          adapter_class.new(mapper, uri)
        end

        private

        def load_dependency
          if [:sql, :memory].include?(name)
            require "lotus/model/adapters/#{name}_adapter"
          end
        end

        def adapter_class
          @class_name ||= Lotus::Utils::String.new("#{name}_adapter").classify
          begin
            Lotus::Utils::Class.load!(class_name, Lotus::Model::Adapters)
          rescue
            raise AdapterNotFound
          end
        end
      end
    end
  end
end
