module Hanami
  module Model
    module Associations
      # Many-To-Many association
      #
      # @since 0.7.0
      # @api private
      class ManyToMany
        # @since 0.7.0
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
        attr_reader :through

        def initialize(repository, source, target, subject, scope = nil)
          @repository = repository
          @source     = source
          @target     = target
          @subject    = subject.to_hash unless subject.nil?
          @scope      = scope || _build_scope
          @through    = relation(source).associations[target].through.to_sym
          freeze
        end

        def to_a
          scope.to_a
        end
        
        # @since x.x.x
        # @api private
        def add(*data) #Can receive an array of entities/hashes with pks.
          command(:create, relation(through), use: [:timestamps])
            .call(associate(data))
        end

        # @since x.x.x
        # @api private
        def remove(id) # Wrap in a transaction
          association_record = relation(through)
            .where(target_foreign_key => id, source_foreign_key => subject.fetch(source_primary_key))
            .one
          ar_id = association_record.public_send relation(through).primary_key
          command( :delete, relation(through), use: [:timestamps] ).by_pk(ar_id).call
        end

        private

        # @since x.x.x
        # @api private
        def container
          repository.container
        end

        # @since x.x.x
        # @api private
        def relation(name)
          repository.relations[name]
        end

        # @since x.x.x
        # @api private
        def command(target, relation, options = {})
          repository.command(target, relation, options)
        end

        # @since x.x.x
        # @api private
        def associate(data)
          relation(target)
            .associations[source]
            .associate(container.relations, data, subject)
        end

        # @since x.x.x
        # @api private
        def source_primary_key
          association_keys[0].first
        end

        # @since x.x.x
        # @api private
        def source_foreign_key
          association_keys[0].last
        end

        # @since x.x.x
        # @api private
        def association_keys
          relation(source)
            .associations[target]
            .__send__(:join_key_map, container.relations)
        end

        # @since x.x.x
        # @api private
        def target_foreign_key
          association_keys[1].first
        end

        # @since x.x.x
        # @api private
        def target_primary_key
          association_keys[1].last
        end

        # @since x.x.x
        # @api private
        def _build_scope
          result = relation(target).qualified
          unless subject.nil?
            result = result
                     .join(through, target_foreign_key => target_primary_key)
                     .where(source_foreign_key => subject.fetch(source_primary_key))
          end
          result.as(Model::MappedRelation.mapper_name)
        end
      end
    end
  end
end
