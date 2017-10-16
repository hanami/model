require 'hanami/model/types'

module Hanami
  module Model
    module Associations
      # Many-To-One association
      #
      # @since 1.1.0
      # @api private
      class BelongsTo
        # @since 1.1.0
        # @api private
        def self.schema_type(entity)
          Sql::Types::Schema::AssociationType.new(entity)
        end

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

        # @since 1.1.0
        # @api private
        def one
          scope.one
        end

        private

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
        def relation(name)
          repository.relations[Hanami::Utils::String.pluralize(name)]
        end

        # @since 1.1.0
        # @api private
        def foreign_key
          association_keys.last
        end

        # Returns primary key and foreign key
        #
        # @since 1.1.0
        # @api private
        def association_keys
          association
            .__send__(:join_key_map, container.relations)
        end

        # Return the ROM::Associations for the source relation
        #
        # @since 1.1.9
        # @api private
        def association
          relation(source).associations[target]
        end

        # @since 1.1.0
        # @api private
        def _build_scope
          result = relation(association.target.to_sym)
          result = result.where(foreign_key => subject.fetch(primary_key)) unless subject.nil?
          result.as(Model::MappedRelation.mapper_name)
        end
      end
    end
  end
end
