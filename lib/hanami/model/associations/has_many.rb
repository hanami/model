module Hanami
  module Model
    module Associations
      class HasMany
        attr_reader :repository, :source, :target, :subject, :scope

        def initialize(repository, source, target, subject, scope = nil)
          @repository = repository
          @source     = source
          @target     = target
          @subject    = subject.to_h
          @scope      = scope || _build_scope
          freeze
        end

        def add(data)
          command(:create, relation(target), use: [:timestamps])
            .call(associate(data))
        end

        def remove(id)
          target_relation = relation(target)

          command(:update, target_relation.where(target_relation.primary_key => id), use: [:timestamps])
            .call(unassociate)
        end

        def delete
          scope.delete
        end

        def each(&blk)
          scope.each(&blk)
        end

        def map(&blk)
          to_a.map(&blk)
        end

        def to_a
          scope.to_a
        end

        def where(condition)
          __new__(scope.where(condition))
        end

        def count
          scope.count
        end

        private

        def command(target, relation, options = {})
          repository.command(target, relation, options)
        end

        def relation(name)
          repository.relations[name]
        end

        def association(name)
          relation(target).associations[name]
        end

        def associate(data)
          relation(source)
            .associations[target]
            .associate(container.relations, data, subject)
        end

        def unassociate
          { foreign_key => nil }
        end

        def container
          repository.container
        end

        def primary_key
          association_keys.first
        end

        def foreign_key
          association_keys.last
        end

        # Returns primary key and foreign key
        def association_keys
          relation(source)
            .associations[target]
            .__send__(:join_key_map, container.relations)
        end

        def _build_scope
          relation(target)
            .where(foreign_key => subject.fetch(primary_key))
            .as(:entity)
        end

        def __new__(new_scope)
          self.class.new(repository, source, target, subject, new_scope)
        end
      end
    end
  end
end
