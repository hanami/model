module Lotus
  module Repository
    # Timestamps handling using an entity's @created_at and @updated_at.
    #
    # @since x.x.x
    module Timestamps
      # Override existing public API into hosting class to support @created_at
      # and @updated_at using Ruby implementations (database agnostic).
      #
      # @since x.x.x
      #
      # @example
      #   require 'lotus/model'
      #
      #   class UserRepository
      #     include Lotus::Repository
      #     include Lotus::Repository::Timestamps
      #   end
      def self.included(base)
        base.class_eval do
          extend ClassMethods
        end
      end

      module ClassMethods
        # Before creating or updating a record in the database for the given
        # entity, sets the entity's @created_at and @updated_at to the current
        # time in UTC. @created_at is left untouched if already set.
        #
        # @param entity [#id, #id=] the entity to persist
        #
        # @return [Object] the entity
        #
        # @since x.x.x
        #
        # @see Lotus::Repository#persist
        #
        # @example With a non persisted entity
        #   require 'lotus/model'
        #
        #   class ArticleRepository
        #     include Lotus::Repository
        #     include Lotus::Repository::Timestamps
        #   end
        #
        #   article = Article.new(title: 'Introducing Lotus::Model')
        #   article.id # => nil
        #   article.created_at # => nil
        #   article.updated_at # => nil
        #
        #   ArticleRepository.persist(article) # creates a record
        #   article.id # => 23
        #   article.created_at # => 2015-02-20 10:00:00 UTC
        #   article.updated_at # => 2015-02-20 10:00:00 UTC
        #
        # @example With a persisted entity
        #   require 'lotus/model'
        #
        #   class ArticleRepository
        #     include Lotus::Repository
        #     include Lotus::Repository::Timestamps
        #   end
        #
        #   article = ArticleRepository.find(23)
        #   article.id # => 23
        #   article.created_at # => 2015-02-20 10:00:00 UTC
        #   article.updated_at # => 2015-02-20 10:00:00 UTC
        #
        #   article.title = 'Launching Lotus::Model'
        #   ArticleRepository.persist(article) # updates the record
        #   article.created_at # => 2015-02-20 10:00:00 UTC
        #   article.updated_at # => 2015-02-20 10:20:35 UTC
        #
        #   article = ArticleRepository.find(23)
        #   article.title # => "Launching Lotus::Model"
        #   article.created_at # => 2015-02-20 10:00:00 UTC
        #   article.updated_at # => 2015-02-20 10:20:35 UTC
        def persist(entity)
          _update_timestamps(entity)
          super
        end

        # Before creating a record in the database for the given entity, sets
        # the entity's @created_at and @updated_at to the current time in UTC.
        # @created_at is left untouched if already set.
        #
        # If already persisted (`id` present) it does nothing.
        #
        # @param entity [#id,#id=] the entity to create
        #
        # @return [Object] the entity
        #
        # @since x.x.x
        #
        # @see Lotus::Repository#create
        #
        # @example
        #   require 'lotus/model'
        #
        #   class ArticleRepository
        #     include Lotus::Repository
        #     include Lotus::Repository::Timestamps
        #   end
        #
        #   article = Article.new(title: 'Introducing Lotus::Model')
        #   article.id # => nil
        #   article.created_at # => nil
        #   article.updated_at # => nil
        #
        #   ArticleRepository.create(article) # creates a record
        #   article.id # => 23
        #   article.created_at # => 2015-02-20 10:00:00 UTC
        #   article.updated_at # => 2015-02-20 10:00:00 UTC
        #
        #   ArticleRepository.create(article) # no-op
        def create(entity)
          _update_timestamps(entity) unless entity.id
          super
        end

        # Before updating a record in the database corresponding to the given
        # entity, sets the entity's @created_at and @updated_at to the current
        # time in UTC. @created_at is left untouched if already set.
        #
        # If not already persisted (`id` present) it raises an exception.
        #
        # @param entity [#id] the entity to update
        #
        # @return [Object] the entity
        #
        # @raise [Lotus::Model::NonPersistedEntityError] if the given entity
        #   wasn't already persisted.
        #
        # @since x.x.x
        #
        # @see Lotus::Repository#update
        # @see Lotus::Model::NonPersistedEntityError
        #
        # @example With a persisted entity
        #   require 'lotus/model'
        #
        #   class ArticleRepository
        #     include Lotus::Repository
        #     include Lotus::Repository::Timestamps
        #   end
        #
        #   article = ArticleRepository.find(23)
        #   article.id # => 23
        #   article.created_at # => 2015-02-20 10:00:00 UTC
        #   article.updated_at # => 2015-02-20 10:00:00 UTC
        #   article.title = 'Launching Lotus::Model'
        #
        #   ArticleRepository.update(article) # updates the record
        #   article.created_at # => 2015-02-20 10:00:00 UTC
        #   article.updated_at # => 2015-02-20 10:20:35 UTC
        #
        #
        #
        # @example With a non persisted entity
        #   require 'lotus/model'
        #
        #   class ArticleRepository
        #     include Lotus::Repository
        #   end
        #
        #   article = Article.new(title: 'Introducing Lotus::Model')
        #   article.id # => nil
        #   article.created_at # => nil
        #   article.updated_at # => nil
        #
        #   ArticleRepository.update(article) # raises Lotus::Model::NonPersistedEntityError
        def update(entity)
          _update_timestamps(entity) if entity.id
          super
        end

        private

        # Sets @created_at and @updated_at for the given entity to the current
        # time in UTC. @created_at is left untouched if already set.
        #
        # @param entity [#id] the entity to update
        #
        # @return [Object] the entity
        #
        # @api private
        # @since x.x.x
        def _update_timestamps(entity)
          entity.created_at ||= Time.now.utc
          entity.updated_at = Time.now.utc
          entity
        end
      end
    end
  end
end
