# frozen_string_literal: true

require "rom-repository"
require "hanami/model/entity_name"
require "hanami/model/relation_name"
require "hanami/model/mapped_relation"
require "hanami/model/association"
require "hanami/utils/class"
require "hanami/utils/class_attribute"
require "hanami/utils/io"

module Hanami
  # Mediates between the entities and the persistence layer, by offering an API
  # to query and execute commands on a database.
  #
  #
  #
  # By default, a repository is named after an entity, by appending the
  # `Repository` suffix to the entity class name.
  #
  # @example
  #   require 'hanami/model'
  #
  #   class Article < Hanami::Entity
  #   end
  #
  #   # valid
  #   class ArticleRepository < Hanami::Repository
  #   end
  #
  #   # not valid for Article
  #   class PostRepository < Hanami::Repository
  #   end
  #
  # A repository is storage independent.
  # All the queries and commands are delegated to the current adapter.
  #
  # This architecture has several advantages:
  #
  #   * Applications depend on an abstract API, instead of low level details
  #     (Dependency Inversion principle)
  #
  #   * Applications depend on a stable API, that doesn't change if the
  #     storage changes
  #
  #   * Developers can postpone storage decisions
  #
  #   * Isolates the persistence logic at a low level
  #
  # Hanami::Model is shipped with one adapter:
  #
  #   * SqlAdapter
  #
  #
  #
  # All the queries and commands are private.
  # This decision forces developers to define intention revealing API, instead
  # of leaking storage API details outside of a repository.
  #
  # @example
  #   require 'hanami/model'
  #
  #   # This is bad for several reasons:
  #   #
  #   #  * The caller has an intimate knowledge of the internal mechanisms
  #   #      of the Repository.
  #   #
  #   #  * The caller works on several levels of abstraction.
  #   #
  #   #  * It doesn't express a clear intent, it's just a chain of methods.
  #   #
  #   #  * The caller can't be easily tested in isolation.
  #   #
  #   #  * If we change the storage, we are forced to change the code of the
  #   #    caller(s).
  #
  #   ArticleRepository.new.where(author_id: 23).order(:published_at).limit(8)
  #
  #
  #
  #   # This is a huge improvement:
  #   #
  #   #  * The caller doesn't know how the repository fetches the entities.
  #   #
  #   #  * The caller works on a single level of abstraction.
  #   #    It doesn't even know about records, only works with entities.
  #   #
  #   #  * It expresses a clear intent.
  #   #
  #   #  * The caller can be easily tested in isolation.
  #   #    It's just a matter of stubbing this method.
  #   #
  #   #  * If we change the storage, the callers aren't affected.
  #
  #   ArticleRepository.new.most_recent_by_author(author)
  #
  #   class ArticleRepository < Hanami::Repository
  #     def most_recent_by_author(author, limit = 8)
  #       articles.
  #         where(author_id: author.id).
  #           order(:published_at).
  #           limit(limit)
  #     end
  #   end
  #
  # @since 0.1.0
  #
  # @see Hanami::Entity
  # @see http://martinfowler.com/eaaCatalog/repository.html
  # @see http://en.wikipedia.org/wiki/Dependency_inversion_principle
  class Repository < ROM::Repository::Root
    # Plugins for database commands
    #
    # @since 0.7.0
    # @api private
    #
    # @see Hanami::Model::Plugins
    COMMAND_PLUGINS = %i[schema mapping timestamps].freeze

    # Define a new ROM::Command while preserving the defaults used by Hanami itself.
    #
    # It allows the user to define a new command to, for example,
    # create many records at the same time and still get entities back.
    #
    # The first argument is the command and relation it will operate on.
    #
    # @return [ROM::Command] the created command
    #
    # @example
    #   # In this example, calling the create_many method with and array of data,
    #   # would result in the creation of records and return an Array of Task entities.
    #
    #   class TaskRepository < Hanami::Repository
    #     def create_many(data)
    #       command(create: :tasks, result: :many).call(data)
    #     end
    #   end
    #
    # @since 1.2.0
    def command(type, relation: root, **opts, &block)
      opts[:use] = COMMAND_PLUGINS | Array(opts[:use])
      opts[:mapper] = opts.fetch(:mapper, Model::MappedRelation.mapper_name)

      relation.command(type, **opts, &block)
    end

    # Declare associations for the repository
    #
    # NOTE: This is an experimental feature
    #
    # @since 0.7.0
    # @api private
    #
    # @example
    #   class BookRepository < Hanami::Repository
    #     associations do
    #       has_many :books
    #     end
    #   end
    def self.associations(&blk)
      if block_given?
        @associations = blk
      else
        @associations
      end
    end

    # Declare database schema
    #
    # NOTE: This should be used **only** when Hanami can't find a corresponding Ruby type for your column.
    #
    # @since 1.0.0
    #
    # @example
    #   # In this example `name` is a PostgreSQL Enum type that we want to treat like a string.
    #
    #   class ColorRepository < Hanami::Repository
    #     schema do
    #       attribute :id,         Hanami::Model::Sql::Types::Integer
    #       attribute :name,       Hanami::Model::Sql::Types::String
    #       attribute :created_at, Hanami::Model::Sql::Types::DateTime
    #       attribute :updated_at, Hanami::Model::Sql::Types::DateTime
    #     end
    #   end
    def self.schema(&blk)
      if block_given?
        @schema = blk
      else
        @schema
      end
    end

    # Declare mapping between database columns and entity's attributes
    #
    # NOTE: This should be used **only** when there is a name mismatch (eg. in legacy databases).
    #
    # @since 0.7.0
    #
    # @example
    #   class BookRepository < Hanami::Repository
    #     self.relation = :t_operator
    #
    #     mapping do
    #       attribute :id,   from: :operator_id
    #       attribute :name, from: :s_name
    #     end
    #   end
    def self.mapping(&blk)
      if block_given?
        @mapping = blk
      else
        @mapping
      end
    end

    # @since 0.7.0
    # @api private
    #
    # rubocop:disable Metrics/MethodLength
    def self.[](relation_name)
      Class.new(Hanami::Repository) do
        root relation_name
        def self.inherited(klass)
          klass.class_eval <<~CODE, __FILE__, __LINE__ + 1
            include Utils::ClassAttribute

            auto_struct false

            @associations = nil
            @mapping = nil
            @schema = nil

            class_attribute :entity
            class_attribute :entity_name
            class_attribute :relation

            self.entity_name = Model::EntityName.new(name)
            self.relation = :#{root}


            commands :create, update: :by_pk, delete: :by_pk, mapper: :entity, use: COMMAND_PLUGINS
            prepend Commands
          CODE

          Hanami::Model.repositories << klass
        end
      end
    end

    # rubocop:enable Metrics/MethodLength

    # Extend commands from ROM::Repository with error management
    #
    # @since 0.7.0
    module Commands
      # Create a new record
      #
      # @return [Hanami::Entity] a new created entity
      #
      # @raise [Hanami::Model::Error] an error in case the command fails
      #
      # @since 0.7.0
      #
      # @example Create From Hash
      #   user = UserRepository.new.create(name: 'Luca')
      #
      # @example Create From Entity
      #   entity = User.new(name: 'Luca')
      #   user   = UserRepository.new.create(entity)
      #
      #   user.id   # => 23
      #   entity.id # => nil - It doesn't mutate original entity
      def create(*args)
        super
      rescue => exception
        raise Hanami::Model::Error.for(exception)
      end

      # Update a record
      #
      # @return [Hanami::Entity] an updated entity
      #
      # @raise [Hanami::Model::Error] an error in case the command fails
      #
      # @since 0.7.0
      #
      # @example Update From Data
      #   repository = UserRepository.new
      #   user       = repository.create(name: 'Luca')
      #
      #   user       = repository.update(user.id, age: 34)
      #
      # @example Update From Entity
      #   repository = UserRepository.new
      #   user       = repository.create(name: 'Luca')
      #
      #   entity     = User.new(age: 34)
      #   user       = repository.update(user.id, entity)
      #
      #   user.age  # => 34
      #   entity.id # => nil - It doesn't mutate original entity
      def update(*args)
        super
      rescue => exception
        raise Hanami::Model::Error.for(exception)
      end

      # Delete a record
      #
      # @return [Hanami::Entity] a deleted entity
      #
      # @raise [Hanami::Model::Error] an error in case the command fails
      #
      # @since 0.7.0
      #
      # @example
      #   repository = UserRepository.new
      #   user       = repository.create(name: 'Luca')
      #
      #   user       = repository.delete(user.id)
      def delete(*args)
        super
      rescue => exception
        raise Hanami::Model::Error.for(exception)
      end
    end

    # Initialize a new instance
    #
    # @return [Hanami::Repository] the new instance
    #
    # @since 0.7.0
    def self.new(configuration:, **options)
      super(configuration.container, options)
    end

    # Find by primary key
    #
    # @return [Hanami::Entity,NilClass] the entity, if found
    #
    # @raise [Hanami::Model::MissingPrimaryKeyError] if the table doesn't
    #   define a primary key
    #
    # @since 0.7.0
    #
    # @example
    #   repository = UserRepository.new
    #   user       = repository.create(name: 'Luca')
    #
    #   user       = repository.find(user.id)
    def find(id)
      root.by_pk(id).map_with(:entity).one
    rescue => exception
      raise Hanami::Model::Error.for(exception)
    end

    # Return all the records for the relation
    #
    # @return [Array<Hanami::Entity>] all the entities
    #
    # @since 0.7.0
    #
    # @example
    #   UserRepository.new.all
    def all
      root.map_with(:entity).to_a
    end

    # Returns the first record for the relation
    #
    # @return [Hanami::Entity,NilClass] first entity, if any
    #
    # @since 0.7.0
    #
    # @example
    #   UserRepository.new.first
    def first
      root.map_with(:entity).limit(1).one
    end

    # Returns the last record for the relation
    #
    # @return [Hanami::Entity,NilClass] last entity, if any
    #
    # @since 0.7.0
    #
    # @example
    #   UserRepository.new.last
    def last
      root.map_with(:entity).limit(1).reverse.one
    end

    # Deletes all the records from the relation
    #
    # @since 0.7.0
    #
    # @example
    #   UserRepository.new.clear
    def clear
      root.delete
    end

    private

    # Returns an association
    #
    # NOTE: This is an experimental feature
    #
    # @since 0.7.0
    # @api private
    def assoc(target, subject = nil)
      Hanami::Model::Association.build(self, target, subject)
    end
  end
end
