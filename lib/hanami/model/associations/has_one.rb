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
          Sql::Types::Schema::AssociationType.new(entity)
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
            command(:create, aggregate(target), mapper: nil).call(serialize(data))
          )
        rescue => e
          raise Hanami::Model::Error.for(e)
        end

        def add(data)
          command(:create, relation(target), mapper: nil).call(associate(serialize(data)))
        rescue => e
          raise Hanami::Model::Error.for(e)
        end

        def update(data)
          command(:update, relation(target), mapper: nil)
            .by_pk(
              one.public_send(relation(target).primary_key)
            ).call(serialize(data))
        rescue => e
          raise Hanami::Model::Error.for(e)
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
        def aggregate(name)
          repository.aggregate(name)
        end

        # @since 1.1.0
        # @api private
        def command(target, relation, options = {})
          repository.command(target, relation, options)
        end

        # @since 1.1.0
        # @api private
        def relation(name)
          repository.relations[Hanami::Utils::String.pluralize(name)]
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
            .associate(container.relations, data, subject)
        end

        # Returns primary key and foreign key
        #
        # @since 1.1.0
        # @api private
        def association_keys
          relation(source)
            .associations[target]
            .__send__(:join_key_map, container.relations)
        end

        # @since 1.1.0
        # @api private
        def _build_scope
          result = relation(target)
          result = result.where(foreign_key => subject.fetch(primary_key)) unless subject.nil?
          result.as(Model::MappedRelation.mapper_name)
        end

        # @since 1.1.0
        # @api private
        def serialize(data)
          Utils::Hash.deep_serialize(data)
        end
      end
    end
  end
end
