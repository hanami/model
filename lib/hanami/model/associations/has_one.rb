# frozen_string_literal: true

require "hanami/utils/hash"

module Hanami
  module Model
    module Associations
      # Many-To-One association
      #
      # @since 1.1.0
      # @api private
      class HasOne
        # @since 1.1.0
        # @api private
        def self.schema_type(entity)
          Sql::Types.Entity(entity)
        end
        #
        # @since 1.1.0
        # @api private
        attr_reader :repository

        # @since 1.1.0
        # @api private
        attr_reader :source

        # @since 1.1.0
        # @api private
        attr_reader :target

        # @since 1.1.0
        # @api private
        attr_reader :subject

        # @since 1.1.0
        # @api private
        attr_reader :scope

        # @since 1.1.0
        # @api private
        def initialize(repository, source, target, subject, scope = nil)
          @repository = repository
          @source     = source
          @target     = target
          @subject    = subject.to_hash unless subject.nil?
          @scope      = scope || _build_scope
          freeze
        end

        def one
          scope.one
        end

        def create(data)
          entity.new(
            command(:create, combine(target), mapper: nil).call(serialize(data))
          )
        rescue => exception
          raise Hanami::Model::Error.for(exception)
        end

        def add(data)
          command(:create, relation(target)).call(associate(serialize(data)))
        rescue => exception
          raise Hanami::Model::Error.for(exception)
        end

        def update(data)
          command(:update, relation(target), mapper: nil)
            .by_pk(
              one.public_send(relation(target).primary_key)
            ).call(serialize(data))
        rescue => exception
          raise Hanami::Model::Error.for(exception)
        end

        def delete
          scope.delete
        end
        alias remove delete

        def replace(data)
          repository.transaction do
            delete
            add(serialize(data))
          end
        end

        private

        # @since 1.1.0
        # @api private
        def entity
          repository.class.entity
        end

        # @since 1.1.0
        # @api private
        def combine(name)
          repository.root.combine(name)
        end

        COMMAND_PLUGINS = %i[schema mapping timestamps].freeze

        # @since 1.1.0
        # @api private
        def command(type, relation, options = {})
          repository.command(type, relation: relation, **options)
        end

        # @since 1.1.0
        # @api private
        def relation(name)
          container.relations[inflector.pluralize(name)]
        end

        # @since 1.1.0
        # @api private
        def container
          repository.container
        end

        # @since 1.1.0
        # @api private
        def primary_key
          association_keys.first
        end

        # @since 1.1.0
        # @api private
        def foreign_key
          association_keys.last
        end

        # @since 1.1.0
        # @api private
        def associate(data)
          relation(source)
            .associations[target]
            .associate(data, subject)
        end

        # Returns primary key and foreign key
        #
        # @since 1.1.0
        # @api private
        def association_keys
          relation(source)
            .associations[target]
            .__send__(:join_key_map)
        end

        # @since 1.1.0
        # @api private
        def _build_scope
          result = relation(target)
          result = result.where(foreign_key => subject.fetch(primary_key)) unless subject.nil?
          result.map_with(Model::MappedRelation.mapper_name)
        end

        # @since 1.1.0
        # @api private
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
