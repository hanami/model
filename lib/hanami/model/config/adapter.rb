require 'hanami/utils/class'

module Hanami
  module Model
    module Config
      # Raised when an adapter class does not exist
      #
      # @since 0.2.0
      class AdapterNotFound < Hanami::Model::Error
        def initialize(adapter_name)
          super "Cannot find Hanami::Model adapter #{adapter_name}"
        end
      end

      # Configuration for the adapter
      #
      # Hanami::Model has its own global configuration that can be manipulated
      # via `Hanami::Model.configure`.
      #
      # New adapter configuration can be registered via `Hanami::Model.adapter`.
      #
      # @see Hanami::Model.adapter
      #
      # @example
      #   require 'hanami/model'
      #
      #   Hanami::Model.configure do
      #     adapter type: :sql, uri: 'postgres://localhost/database'
      #   end
      #
      #   Hanami::Model.configuration.adapter_config
      #   # => Hanami::Model::Config::Adapter(type: :sql, uri: 'postgres://localhost/database')
      #
      # By convention, Hanami inflects type to find the adapter class
      # For example, if type is :sql, derived class will be `Hanami::Model::Adapters::SqlAdapter`
      #
      # @since 0.2.0
      class Adapter
        # @return [Symbol] the adapter name
        #
        # @since 0.2.0
        attr_reader :type

        # @return [String] the adapter URI
        #
        # @since 0.2.0
        attr_reader :uri

        # @return [Hash] a list of non-mandatory options for the adapter
        #
        attr_reader :options

        # @return [String] the adapter class name
        #
        # @since 0.2.0
        attr_reader :class_name

        # Initialize an adapter configuration instance
        #
        # @param options [Hash] configuration options
        # @option options [Symbol] :type adapter type name
        # @option options [String] :uri adapter URI
        #
        # @return [Hanami::Model::Config::Adapter] a new apdapter configuration's
        #   instance
        #
        # @since 0.2.0
        def initialize(**options)
          opts     = options.dup

          @type    = opts.delete(:type)
          @uri     = opts.delete(:uri)
          @options = opts

          @class_name ||= Hanami::Utils::String.new("#{@type}_adapter").classify
        end

        # Initialize the adapter
        #
        # @param mapper [Hanami::Model::Mapper] the mapper instance
        #
        # @return [Hanami::Model::Adapters::SqlAdapter, Hanami::Model::Adapters::MemoryAdapter] an adapter instance
        #
        # @see Hanami::Model::Adapters
        #
        # @since 0.2.0
        def build(mapper)
          load_adapter
          instantiate_adapter(mapper)
        end

        private

        def load_adapter
          begin
            require "hanami/model/adapters/#{type}_adapter"
          rescue LoadError => e
            raise LoadError.new("Cannot find Hanami::Model adapter '#{type}' (#{e.message})")
          end
        end

        def instantiate_adapter(mapper)
          begin
            klass = Hanami::Utils::Class.load!(class_name, Hanami::Model::Adapters)
            klass.new(mapper, uri, options)
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
