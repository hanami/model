require 'rom'
require 'hanami/entity'
require 'hanami/repository'

module Hanami
  # Hanami persistence
  module Model
    require 'hanami/model/version'
    require 'hanami/model/configuration'
    require 'hanami/model/configurator'
    require 'hanami/model/mapping'
    require 'hanami/model/plugins'

    class Error < ::StandardError
    end

    module_function

    class << self
      attr_reader :config
      attr_reader :loaded
      alias loaded? loaded
    end

    def configure(&block)
      @config = Configurator.build(&block)
    end

    def configuration
      @configuration ||= Configuration.new(config)
    end

    def container
      raise 'Not loaded' unless loaded?
      @container
    end

    def load!(&blk)
      configuration.setup.auto_registration(config.directory.to_s) unless config.directory.nil?
      configuration.instance_eval(&blk)                            if     block_given?

      @container = ROM.container(configuration)
      @loaded    = true
    end
  end
end
