module Lotus
  module Model
    module Associations
      # Entities Association ManyToOne relationship
      class ManyToOne
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
          @foreign_key = opts.fetch(:foreign_key) {default_foreign_key}
          @repository  = nil
        end

        # @since x.x.x
        # @api private
        def associate_entities!(entities)
          entities.map do |entity|
            entity.send("#{@name}=", @repository.find(entity.send(@foreign_key)))
            entity
          end
        end

        private
        # Default Foreign key's name
        #
        # It's possible to overwrite this through foreign_key attribute
        # inside mapping via association method.
        #
        # @api private
        # @since x.x.x
        def default_foreign_key
          "#{@name}_id"
        end
      end
    end
  end
end
