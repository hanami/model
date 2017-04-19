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

        def initialize(repository, source, target, subject, scope = nil)
          @repository = repository
          @source     = source
          @target     = target
          @subject    = subject.to_hash unless subject.nil?
          @scope      = scope || _build_scope
          freeze
        end

        private

        # @since x.x.x
        # @api private
        def relation(name)
          repository.relations[Hanami::Utils::String.pluralize(name)]
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
