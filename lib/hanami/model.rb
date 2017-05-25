require 'rom'
require 'concurrent'
require 'hanami/entity'
require 'hanami/repository'

# Hanami
#
# @since 0.1.0
module Hanami
  # Hanami persistence
  #
  # @since 0.1.0
  module Model
    require 'hanami/model/version'
    require 'hanami/model/error'
    require 'hanami/model/configuration'
    require 'hanami/model/configurator'
    require 'hanami/model/mapping'
    require 'hanami/model/plugins'

    # @api private
    # @since 0.7.0
    @__repositories__ = Concurrent::Array.new

    class << self
      # @since 0.7.0
      # @api private
      attr_reader :config

      # @since 0.7.0
      # @api private
      attr_reader :loaded

      # @since 0.7.0
      # @api private
      alias loaded? loaded
    end

    # Configure the framework
    #
    # @since 0.1.0
    #
    # @example
    #   require 'hanami/model'
    #
    #   Hanami::Model.configure do
    #     adapter :sql, ENV['DATABASE_URL']
    #
    #     migrations 'db/migrations'
    #     schema     'db/schema.sql'
    #   end
    def self.configure(&block)
      @config = Configurator.build(&block)
      self
    end

    # Current configuration
    #
    # @since 0.1.0
    def self.configuration
      @configuration ||= Configuration.new(config)
    end

    # @since 0.7.0
    # @api private
    def self.repositories
      @__repositories__
    end

    # @since 0.7.0
    # @api private
    def self.container
      raise 'Not loaded' unless loaded?
      @container
    end

    # @since 0.1.0
    def self.load!(&blk)
      @container = configuration.load!(repositories, &blk)
      @loaded    = true
    end

    # Disconnect from the database
    #
    # This is useful for reboot applications in production and to ensure that
    # the framework prunes stale connections.
    #
    # @since x.x.x
    #
    # @example With Full Stack Hanami Project
    #   # config/puma.rb
    #   # ...
    #   on_worker_boot do
    #     Hanami.boot
    #   end
    #
    # @example With Standalone Hanami::Model
    #   # config/puma.rb
    #   # ...
    #   on_worker_boot do
    #     Hanami::Model.disconnect
    #     Hanami::Model.load!
    #   end
    def self.disconnect
      configuration.connection && configuration.connection.disconnect
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
