module Hanami
  module Model
    module Associations
      class Dsl
        def initialize(repository, &blk)
          @repository = repository
          instance_eval(&blk)
        end

        def has_many(relation, *)
          @repository.__send__(:relations, relation)
        end

        def belongs_to(*)
        end
      end
    end
  end
end
