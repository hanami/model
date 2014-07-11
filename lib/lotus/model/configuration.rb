require 'lotus/utils/class'
require 'lotus/utils/kernel'
require 'lotus/utils/string'

require 'lotus/model/adapters/memory_adapter'
require 'lotus/model/adapters/sql_adapter'
require 'lotus/model/config/adapter'

module Lotus
  module Model
    # Configuration for the framework, adapter and mapper.
    #
    # Lotus::Model has its own global configuration that can be manipulated
    # via `Lotus::Model.configure`.
    #
    # Every time that `Lotus::Model` is included, that
    # global configuration is being copied to the recipient. The copy will
    # inherit all the settings from the original, but all the subsequent changes
    # aren't reflected from the parent to the children, and viceversa.
    #
    # This architecture allows to have a global configuration that capture the
    # most common cases for an application, and let views and layouts
    # to specify exceptions.
    #
    # @since 0.2.0
    class Configuration
      # Default adapter types
      #
      # @since 0.2.0
      # @api private

      # Return the original configuration of the framework instance associated
      # with the given class.
      #
      # When multiple instances of Lotus::Model are used in the same application,
      # we want to make sure that a repository or a datamapper will receive the
      # expected configuration.
      #
      # @param base [Class] a repository or a data mapper
      #
      # @return [Lotus::Model::Configuration] the configuration associated
      #   to the given class.
      #
      # @since 0.2.0
      # @api private
      #
      # @example Direct usage of the framework
      #   require 'lotus/model'
      #
      #   class ArticleRepository
      #     include Lotus::Repository
      #   end
      #   
      #   
      #
      #   Lotus::Model::Configuration.for(ArticleRepository)
      #     # => will return from Lotus::Model
      #
      # @example Multiple instances of the framework
      #   require 'lotus/model'
      #
      #   module MyApp
      #     Model = Lotus::Model.duplicate(self)
      #
      #     class ArticleRepository
      #       include Model
      #     end
      #   end
      #   
      #
      #   class PostRespository
      #     include Lotus::Model
      #   end
      #
      #   Lotus::View::Configuration.for(PostRespository)
      #     # => will return from Lotus::Model
      #
      #   Lotus::View::Configuration.for(MyApp::ArticleRepository)
      #     # => will return from MyApp::Model
      def self.for(base)
        # TODO this implementation is similar to Lotus::Controller::Configuration consider to extract it into Lotus::Utils
        namespace = Utils::String.new(base).namespace
        framework = Utils::Class.load!("(#{namespace}|Lotus)::Model")
        framework.configuration
      end

      # Initialize a configuration instance
      #
      # @return [Lotus::Model::Configuration] a new configuration's instance
      #
      # @since 0.2.0
      def initialize
        @namespace = Object
        reset!
      end

      # Duplicate by copying the settings in a new instance.
      #
      # @return [Lotus::Model::Configuration] a copy of the configuration
      #
      # @since 0.2.0
      # @api private
      def duplicate
        Configuration.new.tap do |c|
          c.namespace  = namespace
          c.root       = root
          c.layout     = @layout # lazy loading of the class
          c.load_paths = load_paths.dup
        end
      end

      # Load the configuration for the current framework
      #
      # @since 0.2.0
      # @api private
      def load!
      end

      # Reset all the values to the defaults
      #
      # @since 0.2.0
      # @api private
      def reset!
        @adapters        = Hash.new
        @default_adapter = nil
      end

      # Add new adapter for the current app
      #
      # @param [Symbol] name The adapter's name to be referenced later in data-mapper
      # @param [String] url The adapter's url
      # @param [Hash] opts Options of the adapter
      # @option opts [Symbol, String] :type Type of the adapter, 
      #   if type is Symbol, it will be inflected from symbol to class
      #   if type is String, it will be constantize.
      #
      # @option opts [Boolean] :default Mark this adapter as default, default to false
      #
      # @since 0.2.0
      # @api private
      #
      # @example
      #   Lotus::Model.configure do
      #     adapter :main_db, 'postgres://localhost/database', type: :sql, default: true
      #     adapter :remote_api, 'http://example.com', type: 'MyApp::Adapters::MyRemoteAdapter'
      #   end
      def adapter(name, url, type: :memory, default: false)
        options = {
          type: type,
          default: default
        }

        adapter = Lotus::Model::Config::Adapter.new(url, options[:type])
        @adapters.merge!({name.to_sym => adapter})

        @default_adapter = adapter if options[:default]
      end

      alias_method :unload!, :reset!

      # Get all the adapter configurations in the registry
      attr_reader :adapters

      # Get the default adapter configuration from the registry
      attr_reader :default_adapter
    end
  end
end
