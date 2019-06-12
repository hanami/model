# frozen_string_literal: true

require "hanami/model/types"

module Hanami
  module Model
    module Associations
      # One-To-Many association
      #
      # @since 0.7.0
      # @api private
      class HasMany # rubocop:disable Metrics/ClassLength
        # @since 0.7.0
        # @api private
        def self.schema_type(entity)
          Sql::Types.Collection(entity)
        end

        # @since 0.7.0
        # @api private
        attr_reader :repository

        # @since 0.7.0
        # @api private
        attr_reader :source

        # @since 0.7.0
        # @api private
        attr_reader :target

        # @since 0.7.0
        # @api private
        attr_reader :subject

        # @since 0.7.0
        # @api private
        attr_reader :scope

        # @since 0.7.0
        # @api private
        def initialize(repository, source, target, subject, scope = nil)
          @repository = repository
          @source     = source
          @target     = target
          @subject    = subject.to_hash unless subject.nil?
          @scope      = scope || _build_scope
          freeze
        end

        # @since 0.7.0
        # @api private
        def create(data)
          entity.new(command(:create, combine(target), mapper: nil, use: [:timestamps])
            .call(serialize(data)))
        rescue => e
          raise Hanami::Model::Error.for(e)
        end

        # @since 0.7.0
        # @api private
        def add(data)
          command(:create, relation(target), use: [:timestamps])
            .call(associate(serialize(data)))
        rescue => e
          raise Hanami::Model::Error.for(e)
        end

        # @since 0.7.0
        # @api private
        def remove(id)
          command(:update, relation(target), use: [:timestamps])
            .by_pk(id)
            .call(unassociate)
        end

        # @since 0.7.0
        # @api private
        def delete
          scope.delete
        end

        # @since 0.7.0
        # @api private
        def each(&blk)
          scope.each(&blk)
        end

        # @since 0.7.0
        # @api private
        def map(&blk)
          to_a.map(&blk)
        end

        # @since 0.7.0
        # @api private
        def to_a
          scope.to_a
        end

        # @since 0.7.0
        # @api private
        def where(condition)
          __new__(scope.where(condition))
        end

        # @since 0.7.0
        # @api private
        def count
          scope.count
        end

        private

        # @since 0.7.0
        # @api private
        def command(type, relation, options = {})
          repository.command(type, relation: relation, **options)
        end

        # @since 0.7.0
        # @api private
        def entity
          repository.class.entity
        end

        # @since 0.7.0
        # @api private
        def relation(name)
          container.relations[inflector.pluralize(name)]
        end

        # @since 0.7.0
        # @api private
        def combine(name)
          repository.root.combine(name)
        end

        # @since 0.7.0
        # @api private
        def association(name)
          relation(target).associations[name]
        end

        # @since 0.7.0
        # @api private
        def associate(data)
          relation(source)
            .associations[target]
            .associate(data, subject)
        end

        # @since 0.7.0
        # @api private
        def unassociate
          { foreign_key => nil }
        end

        # @since 0.7.0
        # @api private
        def container
          repository.container
        end

        # @since 0.7.0
        # @api private
        def primary_key
          association_keys.first
        end

        # @since 0.7.0
        # @api private
        def foreign_key
          association_keys.last
        end

        # Returns primary key and foreign key
        #
        # @since 0.7.0
        # @api private
        def association_keys
          target_association
            .__send__(:join_key_map)
        end

        # Returns the targeted association for a given source
        #
        # @since 0.7.0
        # @api private
        def target_association
          relation(source).associations[target]
        end

        # @since 0.7.0
        # @api private
        def _build_scope
          result = relation(target_association.target.name.to_sym)
          result = result.where(foreign_key => subject.fetch(primary_key)) unless subject.nil?
          result.map_with(:entity)
        end

        # @since 0.7.0
        # @api private
        def __new__(new_scope)
          self.class.new(repository, source, target, subject, new_scope)
        end

        def serialize(data)
          Utils::Hash.deep_serialize(data)
        end

        # @since x.x.x
        # @api private
        def inflector
          Model.configuration.inflector
        end
      end
    end
  end
end
