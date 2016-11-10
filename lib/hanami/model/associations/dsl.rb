module Hanami
  module Model
    module Associations
      # Auto-infer relations linked to repository's associations
      #
      # @since x.x.x
      # @api private
      class Dsl
        # @since x.x.x
        # @api private
        def initialize(repository, &blk)
          @repository = repository
          instance_eval(&blk)
        end

        # @since x.x.x
        # @api private
        def has_many(relation, *)
          @repository.__send__(:relations, relation)
        end

        # @since x.x.x
        # @api private
        def belongs_to(*)
        end
      end
    end
  end
end
