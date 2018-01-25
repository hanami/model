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
          type = Sql::Types::Schema::AssociationType.new(entity)
          Types::Strict::Array.of(type)
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

        # Return the association table object. Would need an aditional query to return the entity
        #
        # @since 1.1.0
        # @api private
        def add(*data)
          command(:create, relation(through), use: [:timestamps])
            .call(associate(serialize(data)))
        rescue => e
          raise Hanami::Model::Error.for(e)
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
                               .one

          return if association_record.nil?

          ar_id = association_record.public_send relation(through).primary_key
          command(:delete, relation(through)).by_pk(ar_id).call
        end
        # rubocop:enable Metrics/AbcSize

        private

        def method_missing(meth, args)
          whitelisted_methods = %i[where order limit]
          return super unless whitelisted_methods.member?(meth) && scope.respond_to?(meth)
          __new__(scope.public_send(meth, args))
        end

        def respond_to_missing?(meth, include_all)
          scope.respond_to?(meth, include_all)
        end

        # @since 1.1.0
        # @api private
        def container
          repository.container
        end

        # @since 1.1.0
        # @api private
        def relation(name)
          repository.relations[name]
        end

        # @since 1.1.0
        # @api private
        def command(target, relation, options = {})
          repository.command(target, relation, options)
        end

        # @since 1.1.0
        # @api private
        def associate(data)
          relation(target)
            .associations[source]
            .associate(container.relations, data, subject)
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
            .__send__(:join_key_map, container.relations)
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
          result = relation(association.target.to_sym).qualified
          unless subject.nil?
            result = result
                     .join(through, target_foreign_key => target_primary_key)
                     .where(source_foreign_key => subject.fetch(source_primary_key))
          end
          result.as(Model::MappedRelation.mapper_name)
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
      end
    end
  end
end
