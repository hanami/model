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
        def has_many(relation, *)
        end

        # @since 1.1.0
        # @api private
        def has_one(relation, *)
        end

        # @since 1.1.0
        # @api private
        def belongs_to(relation, *)
        end
      end
      # rubocop:enable Naming/PredicateName
    end
  end
end
