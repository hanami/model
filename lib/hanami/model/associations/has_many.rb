require 'hanami/model/types'

module Hanami
  module Model
    module Associations
      # One-To-Many association
      #
      # @since x.x.x
      # @api private
      class HasMany
        # @since x.x.x
        # @api private
        def self.schema_type(entity)
          type = Sql::Types::Schema::AssociationType.new(entity)
          Types::Strict::Array.member(type)
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
          @subject    = subject.to_h
          @scope      = scope || _build_scope
          freeze
        end

        # @since x.x.x
        # @api private
        def add(data)
          command(:create, relation(target), use: [:timestamps])
            .call(associate(data))
        end

        # @since x.x.x
        # @api private
        def remove(id)
          target_relation = relation(target)

          command(:update, target_relation.where(target_relation.primary_key => id), use: [:timestamps])
            .call(unassociate)
        end

        # @since x.x.x
        # @api private
        def delete
          scope.delete
        end

        # @since x.x.x
        # @api private
        def each(&blk)
          scope.each(&blk)
        end

        # @since x.x.x
        # @api private
        def map(&blk)
          to_a.map(&blk)
        end

        # @since x.x.x
        # @api private
        def to_a
          scope.to_a
        end

        # @since x.x.x
        # @api private
        def where(condition)
          __new__(scope.where(condition))
        end

        # @since x.x.x
        # @api private
        def count
          scope.count
        end

        private

        # @since x.x.x
        # @api private
        def command(target, relation, options = {})
          repository.command(target, relation, options)
        end

        # @since x.x.x
        # @api private
        def relation(name)
          repository.relations[name]
        end

        # @since x.x.x
        # @api private
        def association(name)
          relation(target).associations[name]
        end

        # @since x.x.x
        # @api private
        def associate(data)
          relation(source)
            .associations[target]
            .associate(container.relations, data, subject)
        end

        # @since x.x.x
        # @api private
        def unassociate
          { foreign_key => nil }
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
        def foreign_key
          association_keys.last
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
          relation(target)
            .where(foreign_key => subject.fetch(primary_key))
            .as(Repository::MAPPER_NAME)
        end

        # @since x.x.x
        # @api private
        def __new__(new_scope)
          self.class.new(repository, source, target, subject, new_scope)
        end
      end
    end
  end
end
