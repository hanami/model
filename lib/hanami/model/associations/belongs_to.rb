require 'hanami/model/types'

module Hanami
  module Model
    module Associations
      # Many-To-One association
      #
      # @since x.x.x
      # @api private
      class BelongsTo
        # @since x.x.x
        # @api private
        def self.schema_type(entity)
          Sql::Types::Schema::AssociationType.new(entity)
        end

        # @since x.x.x
        # @api private
        attr_reader :repository

        # @since x.x.x
        # @api private
        attr_reader :source

        # @since x.x.x
        # @api private
        attr_reader :target

        # @since x.x.x
        # @api private
        attr_reader :subject

        # @since x.x.x
        # @api private
        attr_reader :scope

        # @since x.x.x
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

        private

        # @since x.x.x
        # @api private
        def command(target, relation, options = {})
          repository.command(target, relation, options)
        end

        # @since x.x.x
        # @api private
        def aggregate(name)
          repository.aggregate(name)
        end

        # @since x.x.x
        # @api private
        def entity
          repository.class.entity
        end

        # @since x.x.x
        # @api private
        def container
          repository.container
        end

        # @since x.x.x
        # @api private
        def primary_key
          association_keys.first
        end

        # @since x.x.x
        # @api private
        def relation(name)
          repository.relations[Hanami::Utils::String.new(name).pluralize]
        end

        # @since x.x.x
        # @api private
        def foreign_key
          association_keys.last
        end

        # @since x.x.x
        # @api private
        def associate(data)
          relation(source)
            .associations[target]
            .associate(container.relations, data, subject)
        end

        # Returns primary key and foreign key
        #
        # @since x.x.x
        # @api private
        def association_keys
          relation(source)
            .associations[target]
            .__send__(:join_key_map, container.relations)
        end

        # @since x.x.x
        # @api private
        def _build_scope
          result = relation(target)
          result = result.where(foreign_key => subject.fetch(primary_key)) unless subject.nil?
          result.as(Model::MappedRelation.mapper_name)
        end
      end
    end
  end
end
