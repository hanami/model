require 'lotus/utils/class'

module Lotus
  module Model
    module Config
      # Raised when an adapter class does not exist
      #
      # @since x.x.x
      class AdapterNotFound < ::StandardError
        def initialize(adapter_name)
          super "Cannot find Lotus::Model adapter #{adapter_name}"
        end
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
        #
        # @return [Lotus::Model::Config::Adapter] a new apdapter configuration's
        #   instance
        #
        # @since x.x.x
        def initialize(name, uri = nil)
          @name = name
          @uri  = uri
          @class_name ||= Lotus::Utils::String.new("#{name}_adapter").classify
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
          instantiate_adapter(mapper)
        end

        private

        def load_dependency
          begin
            require "lotus/model/adapters/#{name}_adapter"
          rescue LoadError => e
            raise LoadError.new("Cannot find Lotus::Model adapter '#{name}' (#{e.message})")
          end
        end

        def instantiate_adapter(mapper)
          begin
            klass = Lotus::Utils::Class.load!(class_name, Lotus::Model::Adapters)
            klass.new(mapper, uri)
          rescue NameError
            raise AdapterNotFound.new(class_name)
          rescue => e
            raise "Cannot instantiate adapter of #{klass} (#{e.message})"
          end
        end

      end
    end
  end
end
