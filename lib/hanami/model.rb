require 'hanami/model/version'
require 'hanami/entity'
require 'rom-repository'
require 'hanami/model/plugins'

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

  # Hanami persistence
  module Model
    class Error < StandardError
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

    def load!(&block)
      configuration.setup.auto_registration(config.directory.to_s) if config.directory
      configuration.instance_eval(&block) if block_given?
      @container = ROM.container(configuration)
      @loaded = true
    end

    def unload!
      @configuration = nil
      @container     = nil
      @loaded        = false
    end

    def migration(&block)
      ::Hanami::Migration.new(configuration.gateways[:default], &block)
    end

    class Association
      def self.new(repository, target, subject)
        case repository.root.associations[target]
        when ROM::SQL::Association::OneToMany then Associations::HasMany
        else
          raise 'unsupported association'
        end.new(repository, repository.root.name.to_sym, target, subject)
      end
    end

    module Associations
      class HasMany
        attr_reader :repository, :source, :target, :subject, :scope

        def initialize(repository, source, target, subject, scope = nil)
          @repository = repository
          @source     = source
          @target     = target
          @subject    = subject.to_h
          @scope      = scope || _build_scope
          freeze
        end

        def add(data)
          command(:create, relation(target), use: [:timestamps])
            .call(associate(data))
        end

        def remove(id)
          target_relation = relation(target)

          command(:update, target_relation.where(target_relation.primary_key => id), use: [:timestamps])
            .call(unassociate)
        end

        def delete
          scope.delete
        end

        def each(&blk)
          scope.each(&blk)
        end

        def map(&blk)
          to_a.map(&blk)
        end

        def to_a
          scope.to_a
        end

        def where(condition)
          __new__(scope.where(condition))
        end

        def count
          scope.count
        end

        private

        def command(target, relation, options = {})
          repository.command(target, relation, options)
        end

        def relation(name)
          repository.relations[name]
        end

        def association(name)
          relation(target).associations[name]
        end

        def associate(data)
          relation(source)
            .associations[target]
            .associate(container.relations, data, subject)
        end

        def unassociate
          { foreign_key => nil }
        end

        def container
          repository.container
        end

        def primary_key
          association_keys.first
        end

        def foreign_key
          association_keys.last
        end

        # Returns primary key and foreign key
        def association_keys
          relation(source)
            .associations[target]
            .__send__(:join_key_map, container.relations)
        end

        def _build_scope
          relation(target)
            .where(foreign_key => subject.fetch(primary_key))
            .as(:entity)
        end

        def __new__(new_scope)
          self.class.new(repository, source, target, subject, new_scope)
        end
      end
    end

    private

    class Configuration < ROM::Configuration
      attr_reader :mappings

      def initialize(configurator)
        super(configurator.backend, configurator.url)
        @migrations = configurator._migrations
        @schema     = configurator._schema
        @mappings   = {}
      end

      # NOTE: This must be changed when we want to support several adapters at the time
      def url
        environment.gateways[:default].connection.url
      end

      def root
        Hanami.respond_to?(:root) ? Hanami.root : Pathname.pwd
      end

      def migrations
        (@migrations.nil? ? root : root.join(@migrations)).realpath
      end

      def schema
        @schema.nil? ? root : root.join(@schema)
      end

      def define_mappings(root, &blk)
        @mappings[root] = Mapping.new(&blk)
      end
    end

    class Configurator
      attr_reader :backend
      attr_reader :url
      attr_reader :directory
      attr_reader :_migrations
      attr_reader :_schema

      def self.build(&block)
        self.new.tap { |config| config.instance_eval(&block) }
      end

      private

      def adapter(backend, url)
        @backend = backend
        @url = url
      end

      def path(path)
        @directory = path
      end

      def migrations(path)
        @_migrations = path
      end

      def schema(path)
        @_schema = path
      end
    end

    class Mapping
      def initialize(&blk)
        @attributes = {}
        instance_eval(&blk)
        @processor = @attributes.empty? ? ::Hash : Transproc(:rename_keys, @attributes)
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
end
