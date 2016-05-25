require 'hanami/model/version'
require 'hanami/model/plugins'
require 'hanami/entity'
require 'rom'
require 'rom-repository'

module Hanami
  class Migration
    attr_reader :gateway
    attr_reader :migration

    def initialize(gateway, &block)
      @gateway = gateway
      @migration = gateway.migration(&block)
      freeze
    end

    def run(direction = :up)
      migration.apply(gateway.connection, direction)
    end
  end

  module Model
    module_function

    class << self
      attr_reader :config
      attr_reader :loaded
      alias_method :loaded?, :loaded
    end

    def configure(&block)
      @config = Configurator.build(&block)
    end

    def configuration
      @configuration ||= Configuration.new(config.backend, config.dsn)
    end

    def container
      raise 'Not loaded' unless loaded?
      @container
    end

    def load!(&block)
      configuration.setup.auto_registration(config.directory.to_s) if config.directory
      configuration.instance_eval(&block) if block_given?
      @container = ROM.container(configuration)
      @loaded = true
    end

    def migration(&block)
      ::Hanami::Migration.new(configuration.gateways[:default], &block)
    end

    private

    class Configuration < ROM::Configuration
      attr_reader :mappings

      def initialize(*)
        super
        @mappings = {}
      end

      def define_mappings(root, &blk)
        @mappings[root] = Mapping.new(&blk)
      end
    end

    class Configurator
      attr_reader :backend
      attr_reader :dsn
      attr_reader :directory

      def self.build(&block)
        self.new.tap { |config| config.instance_eval(&block) }
      end

      private

      def adapter(backend, dsn)
        @backend = backend
        @dsn = dsn
      end

      def path(path)
        @directory = path
      end
    end

    class Mapping
      def initialize(&blk)
        @attributes = {}
        instance_eval(&blk)
        @processor = Transproc(:rename_keys, @attributes)
      end

      def model(entity)
      end

      def register_as(name)
      end

      def attribute(name, options)
        @attributes[name] = options.fetch(:from, name)
      end

      def process(input)
        @processor[input]
      end
    end
  end

  # Keep this for allowing specialisations
  # class Relation < ROM::SQL::Relation; end # need to talk to Solnic about this

  class Repository < ROM::Repository::Root
    class << self
      def configuration
        Hanami::Model.configuration
      end

      def container
        Hanami::Model.container
      end

      def relation(name, &block)
        configuration.relation(name, &block)
        relations(name)
        root(name)
      end

      def mapping(&block)
        root = self.root
        configuration.mappers { define(root, &block) }
        configuration.define_mappings(root, &block)
      end
    end

    def initialize
      super(self.class.container)
    end
  end
end
