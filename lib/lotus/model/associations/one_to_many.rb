module Lotus
  module Model
    module Associations
      # Entities Association OneToMany relationship
      class OneToMany
        # @attr_reader related collection (the other side of relationship)
        #
        # @since x.x.x
        attr_reader :collection

        # @attr_reader Repository responsible will roots this association
        #
        # @since x.x.x
        attr_accessor :repository

        # Collects initial data to build ManyToOne Association
        # @example
        #
        #   collection: :articles, foreign_key: :article_id, repository: ArticlesRepository
        #
        # @since x.x.x
        def initialize(opts)
          @name        = opts.fetch(:name)
          @collection  = opts.fetch(:collection)
          @foreign_key = opts.fetch(:foreign_key)
          @repository  = nil
        end

        # @since x.x.x
        # @api private
        def associate_entities!(entities)
          entities.map do |entity|
            entity.send("#{@name}=", by_foreign_key(entity.id))
            entity
          end
        end

        private
        # Fetch Relation by its foreign key
        # @api private
        def by_foreign_key(key)
          @repository.send(:query).where(@foreign_key => key).to_a
        end
      end
    end
  end
end
