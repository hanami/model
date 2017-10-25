module Hanami
  module Model
    module Associations
      # Auto-infer relations linked to repository's associations
      #
      # @since 0.7.0
      # @api private
      #
      # rubocop:disable Naming/PredicateName
      class Dsl
        # @since 0.7.0
        # @api private
        def initialize(repository, &blk)
          @repository = repository
          instance_eval(&blk)
        end

        # @since 0.7.0
        # @api private
        def has_many(relation, **args)
          @repository.__send__(:relations, relation)
          @repository.__send__(:relations, args[:through]) if args[:through]
        end

        # @since 1.1.0
        # @api private
        def has_one(relation, *)
          @repository.__send__(:relations, Hanami::Utils::String.pluralize(relation).to_sym)
        end

        # @since 1.1.0
        # @api private
        def belongs_to(relation, *)
          @repository.__send__(:relations, Hanami::Utils::String.pluralize(relation).to_sym)
        end
      end
      # rubocop:enable Naming/PredicateName
    end
  end
end
