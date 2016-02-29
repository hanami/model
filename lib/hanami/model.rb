require 'hanami/model/version'
require 'hanami/entity'
require 'hanami/entity/dirty_tracking'
require 'hanami/repository'
require 'hanami/model/mapper'
require 'hanami/model/configuration'
require 'hanami/model/error'

module Hanami
  # Model
  #
  # @since 0.1.0
  module Model
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
    # @see Hanami::Model
    #
    # @example
    #   require 'hanami/model'
    #
    #   Hanami::Model.configure do
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
    # The above example has name :sql, thus derived class will be `Hanami::Model::Adapters::SqlAdapter`
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

    # Duplicate Hanami::Model in order to create a new separated instance
    # of the framework.
    #
    # The new instance of the framework will be completely decoupled from the
    # original. It will inherit the configuration, but all the changes that
    # happen after the duplication, won't be reflected on the other copies.
    #
    # @return [Module] a copy of Hanami::Model
    #
    # @since 0.2.0
    # @api private
    #
    # @example Basic usage
    #   require 'hanami/model'
    #
    #   module MyApp
    #     Model = Hanami::Model.dupe
    #   end
    #
    #   MyApp::Model == Hanami::Model # => false
    #
    #   MyApp::Model.configuration ==
    #     Hanami::Model.configuration # => false
    #
    # @example Inheriting configuration
    #   require 'hanami/model'
    #
    #   Hanami::Model.configure do
    #     adapter type: :sql, uri: 'sqlite3://uri'
    #   end
    #
    #   module MyApp
    #     Model = Hanami::Model.dupe
    #   end
    #
    #   module MyApi
    #     Model = Hanami::Model.dupe
    #     Model.configure do
    #       adapter type: :sql, uri: 'postgresql://uri'
    #     end
    #   end
    #
    #   Hanami::Model.configuration.adapter_config.uri # => 'sqlite3://uri'
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
    # @return [Module] a copy of Hanami::Model
    #
    # @since 0.2.0
    #
    # @see Hanami::Model#dupe
    # @see Hanami::Model::Configuration
    #
    # @example Basic usage
    #   require 'hanami/model'
    #
    #   module MyApp
    #     Model = Hanami::Model.dupe
    #   end
    #
    #   # It will:
    #   #
    #   # 1. Generate MyApp::Model
    #   # 2. Generate MyApp::Entity
    #   # 3. Generate MyApp::Repository
    #
    #   MyApp::Model      == Hanami::Model # => false
    #   MyApp::Repository == Hanami::Repository # => false
    #
    # @example Block usage
    #   require 'hanami/model'
    #
    #   module MyApp
    #     Model = Hanami::Model.duplicate(self) do
    #       adapter type: :memory, uri: 'memory://localhost'
    #     end
    #   end
    #
    #   Hanami::Model.configuration.adapter_config # => nil
    #   MyApp::Model.configuration.adapter_config # => #<Hanami::Model::Config::Adapter:0x007ff0ff0244f8 @type=:memory, @uri="memory://localhost", @class_name="MemoryAdapter">
    def self.duplicate(mod, &blk)
      dupe.tap do |duplicated|
        mod.module_eval %{
          Entity = Hanami::Entity.dup
          Repository = Hanami::Repository.dup
        }

        duplicated.configure(&blk) if block_given?
      end
    end

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
      Sequel.migration(&blk)
    end
  end
end
