require 'rom-repository'
require 'hanami/model/entity_name'
require 'hanami/model/relation_name'
require 'hanami/model/associations/dsl'
require 'hanami/model/association'
require 'hanami/utils/class'
require 'hanami/utils/class_attribute'

module Hanami
  class Repository < ROM::Repository::Root
    class << self
      def configuration
        Hanami::Model.configuration
      end

      def container
        Hanami::Model.container
      end

      def define_relation(name, &block)
        configuration.relation(name, &block)
        relations(name)
        root(name)
      end

      def define_mapping(&block)
        root = self.root
        configuration.mappers { define(root, &block) }
        configuration.define_mappings(root, &block)
      end

      def define_associations(&blk)
        Model::Associations::Dsl.new(self, &blk)
      end

      def associations(&blk)
        @associations = blk
      end

      def mapping(&blk)
        @mapping = blk
      end

      def load!
        m = @mapping
        a = @associations
        e = entity

        define_relation(relation) do
          schema(infer: true) do
            associations(&a) unless a.nil?
          end

          def by_primary_key(id)
            where(primary_key => id)
          end
        end

        define_mapping do
          model       Utils::Class.load!(e)
          register_as :entity
          instance_exec(&m) unless m.nil?
        end

        define_associations(&a) unless a.nil?
      end
    end

    def self.inherited(klass)
      klass.class_eval do
        include Utils::ClassAttribute

        class_attribute :entity
        self.entity = Model::EntityName.new(name)

        class_attribute :relation
        self.relation = Model::RelationName.new(name)

        prepend Commands
      end

      configuration.repositories << klass
    end

    module Commands
      def create(*args)
        super
      rescue => e
        raise Hanami::Model::Error.for(e)
      end

      def update(*args)
        super
      rescue => e
        raise Hanami::Model::Error.for(e)
      end

      def delete(*args)
        super
      rescue => e
        raise Hanami::Model::Error.for(e)
      end
    end

    def initialize
      super(self.class.container)
    end

    def find(id)
      root.by_primary_key(id).as(:entity).one
    end

    def all
      root.as(:entity)
    end

    def first
      root.as(:entity).first
    end

    def last
      root.order(Sequel.desc(root.primary_key)).as(:entity).first
    end

    def clear
      root.delete
    end

    private

    def assoc(target, subject)
      Hanami::Model::Association.new(self, target, subject)
    end
  end
end
