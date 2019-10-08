# frozen_string_literal: true

require "hanami/utils/hash"

module Hanami
  module Model
    module Associations
      # Many-To-Many association
      #
      # @since 0.7.0
      # @api private
      class ManyToMany # rubocop:disable Metrics/ClassLength
        # @since 0.7.0
        # @api private
        def self.schema_type(entity)
          Sql::Types.Collection(entity)
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
        attr_reader :through

        def initialize(repository, source, target, subject, scope = nil)
          @repository = repository
          @source     = source
          @target     = target
          @subject    = subject.to_hash unless subject.nil?
          @through    = relation(source).associations[target].through.to_sym
          @scope      = scope || _build_scope
          freeze
        end

        def to_a
          scope.to_a
        end

        def map(&blk)
          to_a.map(&blk)
        end

        def each(&blk)
          scope.each(&blk)
        end

        def count
          scope.count
        end

        def where(condition)
          __new__(scope.where(condition))
        end

        # Return the association table object. Would need an aditional query to return the entity
        #
        # @since 1.1.0
        # @api private
        def add(*data)
          command(:create, relation(through), use: [:timestamps])
            .call(associate(serialize(data)))
        rescue => exception
          raise Hanami::Model::Error.for(exception)
        end

        # @since 1.1.0
        # @api private
        def delete
          relation(through).where(source_foreign_key => subject.fetch(source_primary_key)).delete
        end

        # @since 1.1.0
        # @api private
        # rubocop:disable Metrics/AbcSize
        def remove(target_id)
          association_record = relation(through)
                               .where(target_foreign_key => target_id, source_foreign_key => subject.fetch(source_primary_key))
                               .map_with(Model::MappedRelation.mapper_name)
                               .one

          return if association_record.nil?

          ar_id = association_record.public_send relation(through).primary_key
          command(:delete, relation(through)).by_pk(ar_id).call
        end
        # rubocop:enable Metrics/AbcSize

        private

        # @since 1.1.0
        # @api private
        def container
          repository.container
        end

        # @since 1.1.0
        # @api private
        def relation(name)
          container.relations[inflector.pluralize(name)]
        end

        # @since 1.1.0
        # @api private
        def command(type, relation, options = {})
          repository.command(type, relation: relation, **options)
        end

        # @since 1.1.0
        # @api private
        def associate(data)
          relation(target)
            .associations[source]
            .associate(data, subject)
        end

        # @since 1.1.0
        # @api private
        def source_primary_key
          association_keys[0].first
        end

        # @since 1.1.0
        # @api private
        def source_foreign_key
          association_keys[0].last
        end

        # @since 1.1.0
        # @api private
        def association_keys
          relation(source)
            .associations[target]
            .__send__(:join_key_map)
        end

        # @since 1.1.0
        # @api private
        def target_foreign_key
          association_keys[1].first
        end

        # @since 1.1.0
        # @api private
        def target_primary_key
          association_keys[1].last
        end

        # Return the ROM::Associations for the source relation
        #
        # @since 1.1.0
        # @api private
        def association
          relation(source).associations[target]
        end

        # @since 1.1.0
        #
        # @api private
        # rubocop:disable Metrics/AbcSize
        def _build_scope
          result = relation(association.target.name.to_sym).qualified
          unless subject.nil?
            result = result
                     .join(through, target_foreign_key => target_primary_key)
                     .where(source_foreign_key => subject.fetch(source_primary_key))
          end
          result.map_with(Model::MappedRelation.mapper_name)
        end
        # rubocop:enable Metrics/AbcSize

        # @since 1.1.0
        # @api private
        def __new__(new_scope)
          self.class.new(repository, source, target, subject, new_scope)
        end

        # @since 1.1.0
        # @api private
        def serialize(data)
          data.map do |d|
            Utils::Hash.deep_serialize(d)
          end
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
