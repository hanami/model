require 'lotus/model/version'
require 'lotus/entity'
require 'lotus/repository'
require 'lotus/model/mapper'
require 'lotus/model/configuration'

module Lotus
  # Model
  #
  # @since 0.1.0
  module Model
    # Error for non persisted entity
    # It's raised when we try to update or delete a non persisted entity.
    #
    # @since 0.1.0
    #
    # @see Lotus::Repository.update
    class NonPersistedEntityError < ::StandardError
    end

    # Error for invalid mapper configuration
    # It's raised when mapping is not configured correctly
    #
    # @since 0.2.0
    #
    # @see Lotus::Configuration#mapping
    class InvalidMappingError < ::StandardError
    end

    # Error for invalid query
    # It's raised when a query is malformed
    #
    # @since x.x.x
    class InvalidQueryError < ::StandardError
    end

    include Utils::ClassAttribute

    # Framework configuration
    #
    # @since 0.2.0
    # @api private
    class_attribute :configuration
    self.configuration = Configuration.new

    # Configure the framework.
    # It yields the given block in the context of the configuration
    #
    # @param blk [Proc] the configuration block
    #
    # @since 0.2.0
    #
    # @see Lotus::Model
    #
    # @example
    #   require 'lotus/model'
    #
    #   Lotus::Model.configure do
    #     adapter type: :sql, uri: 'postgres://localhost/database'
    #
    #     mapping do
    #       collection :users do
    #         entity User
    #
    #         attribute :id,   Integer
    #         attribute :name, String
    #       end
    #     end
    #   end
    #
    # Adapter MUST follow the convention in which adapter class is inflection of adapter name
    # The above example has name :sql, thus derived class will be `Lotus::Model::Adapters::SqlAdapter`
    def self.configure(&blk)
      configuration.instance_eval(&blk)
      self
    end

    # Load the framework
    #
    # @since 0.2.0
    # @api private
    def self.load!
      configuration.load!
    end

    # Unload the framework
    #
    # @since 0.2.0
    # @api private
    def self.unload!
      configuration.unload!
    end

    # Duplicate Lotus::Model in order to create a new separated instance
    # of the framework.
    #
    # The new instance of the framework will be completely decoupled from the
    # original. It will inherit the configuration, but all the changes that
    # happen after the duplication, won't be reflected on the other copies.
    #
    # @return [Module] a copy of Lotus::Model
    #
    # @since 0.2.0
    # @api private
    #
    # @example Basic usage
    #   require 'lotus/model'
    #
    #   module MyApp
    #     Model = Lotus::Model.dupe
    #   end
    #
    #   MyApp::Model == Lotus::Model # => false
    #
    #   MyApp::Model.configuration ==
    #     Lotus::Model.configuration # => false
    #
    # @example Inheriting configuration
    #   require 'lotus/model'
    #
    #   Lotus::Model.configure do
    #     adapter type: :sql, uri: 'sqlite3://uri'
    #   end
    #
    #   module MyApp
    #     Model = Lotus::Model.dupe
    #   end
    #
    #   module MyApi
    #     Model = Lotus::Model.dupe
    #     Model.configure do
    #       adapter type: :sql, uri: 'postgresql://uri'
    #     end
    #   end
    #
    #   Lotus::Model.configuration.adapter_config.uri # => 'sqlite3://uri'
    #   MyApp::Model.configuration.adapter_config.uri # => 'sqlite3://uri'
    #   MyApi::Model.configuration.adapter_config.uri # => 'postgresql://uri'
    def self.dupe
      dup.tap do |duplicated|
        duplicated.configuration = Configuration.new
      end
    end

    # Duplicate the framework and generate modules for the target application
    #
    # @param mod [Module] the Ruby namespace of the application
    # @param blk [Proc] an optional block to configure the framework
    #
    # @return [Module] a copy of Lotus::Model
    #
    # @since 0.2.0
    #
    # @see Lotus::Model#dupe
    # @see Lotus::Model::Configuration
    #
    # @example Basic usage
    #   require 'lotus/model'
    #
    #   module MyApp
    #     Model = Lotus::Model.dupe
    #   end
    #
    #   # It will:
    #   #
    #   # 1. Generate MyApp::Model
    #   # 2. Generate MyApp::Entity
    #   # 3. Generate MyApp::Repository
    #
    #   MyApp::Model      == Lotus::Model # => false
    #   MyApp::Repository == Lotus::Repository # => false
    #
    # @example Block usage
    #   require 'lotus/model'
    #
    #   module MyApp
    #     Model = Lotus::Model.duplicate(self) do
    #       adapter type: :memory, uri: 'memory://localhost'
    #     end
    #   end
    #
    #   Lotus::Model.configuration.adapter_config # => nil
    #   MyApp::Model.configuration.adapter_config # => #<Lotus::Model::Config::Adapter:0x007ff0ff0244f8 @type=:memory, @uri="memory://localhost", @class_name="MemoryAdapter">
    def self.duplicate(mod, &blk)
      dupe.tap do |duplicated|
        mod.module_eval %{
          Entity = Lotus::Entity.dup
          Repository = Lotus::Repository.dup
        }

        duplicated.configure(&blk) if block_given?
      end
    end

  end
end
