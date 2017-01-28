require 'rom'
require 'concurrent'
require 'hanami/entity'
require 'hanami/repository'

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
    def self.load!(&blk) # rubocop:disable Metrics/AbcSize
      configuration.gateway.use_logger(configuration.logger)       unless configuration.logger.nil?
      configuration.setup.auto_registration(config.directory.to_s) unless config.directory.nil?
      configuration.instance_eval(&blk)                            if     block_given?
      configuration.configure_gateway
      repositories.each(&:load!)

      @container = ROM.container(configuration)

      configuration.define_entities_mappings(@container, repositories)

      @loaded = true
    rescue => e
      raise Hanami::Model::Error.for(e)
    end
  end
end
