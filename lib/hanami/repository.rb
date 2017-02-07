require 'rom-repository'
require 'hanami/model/entity_name'
require 'hanami/model/relation_name'
require 'hanami/model/mapped_relation'
require 'hanami/model/associations/dsl'
require 'hanami/model/association'
require 'hanami/utils/class'
require 'hanami/utils/class_attribute'

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
  #   class Article
  #     include Hanami::Entity
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
  # leak storage API details outside of a repository.
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
  #   #    It's just a matter of stub this method.
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
    COMMAND_PLUGINS = [:schema, :mapping, :timestamps].freeze

    # Configuration
    #
    # @since 0.7.0
    # @api private
    def self.configuration
      Hanami::Model.configuration
    end

    # Container
    #
    # @since 0.7.0
    # @api private
    def self.container
      Hanami::Model.container
    end

    # Define a database relation, which describes how data is fetched from the
    # database.
    #
    # It auto-infers the underlying database table.
    #
    # @since 0.7.0
    # @api private
    #
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    def self.define_relation
      a = @associations
      s = @schema

      configuration.relation(relation) do
        if s.nil?
          schema(infer: true) do
            associations(&a) unless a.nil?
          end
        else
          schema(&s)
        end
      end

      relations(relation)
      root(relation)
      class_eval %{
        def #{relation}
          Hanami::Model::MappedRelation.new(@#{relation})
        end
      }
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    # Defines the ampping between a database table and an entity.
    #
    # It's also responsible to associate table columns to entity attributes.
    #
    # @since 0.7.0
    # @api private
    #
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    def self.define_mapping
      self.entity = Utils::Class.load!(entity_name)
      e = entity
      m = @mapping

      blk = lambda do |_|
        model       e
        register_as Model::MappedRelation.mapper_name
        instance_exec(&m) unless m.nil?
      end

      root = self.root
      configuration.mappers { define(root, &blk) }
      configuration.define_mappings(root, &blk)
      configuration.register_entity(relation, entity_name.underscore, e)
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    # It defines associations, by adding relations to the repository
    #
    # @since 0.7.0
    # @api private
    #
    # @see Hanami::Model::Associations::Dsl
    def self.define_associations
      Model::Associations::Dsl.new(self, &@associations) unless @associations.nil?
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
      @associations = blk
    end

    # Declare database schema
    #
    # NOTE: This should be used **only** when Hanami can't find a corresponding Ruby type for your column.
    #
    # @since x.x.x
    #
    # @example
    #   # In this example `name` is a PostgreSQL Enum type that we want to treat like a string.
    #
    #   class ColorRepository < Hanami::Repository
    #     schema do
    #       attribute :id,         Hanami::Model::Sql::Types::Int
    #       attribute :name,       Hanami::Model::Sql::Types::String
    #       attribute :created_at, Hanami::Model::Sql::Types::DateTime
    #       attribute :updated_at, Hanami::Model::Sql::Types::DateTime
    #     end
    #   end
    def self.schema(&blk)
      @schema = blk
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
      @mapping = blk
    end

    # Define relations, mapping and associations
    #
    # @since 0.7.0
    # @api private
    def self.load!
      define_relation
      define_mapping
      define_associations
    end

    # @since 0.7.0
    # @api private
    def self.inherited(klass) # rubocop:disable Metrics/MethodLength
      klass.class_eval do
        include Utils::ClassAttribute

        class_attribute :entity

        class_attribute :entity_name
        self.entity_name = Model::EntityName.new(name)

        class_attribute :relation
        self.relation = Model::RelationName.new(name)

        commands :create, update: :by_pk, delete: :by_pk, mapper: Model::MappedRelation.mapper_name, use: COMMAND_PLUGINS
        prepend Commands
      end

      Hanami::Model.repositories << klass
    end

    # Extend commands from ROM::Repository with error management
    #
    # @since 0.7.0
    module Commands
      # Create a new record
      #
      # @return [Hanami::Entity] an new created entity
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
      rescue => e
        raise Hanami::Model::Error.for(e)
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
      rescue => e
        raise Hanami::Model::Error.for(e)
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
      rescue => e
        raise Hanami::Model::Error.for(e)
      end
    end

    # Initialize a new instance
    #
    # @return [Hanami::Repository] the new instance
    #
    # @since 0.7.0
    def initialize
      super(self.class.container)
    end

    # Find by primary key
    #
    # @return [Hanami::Entity,NilClass] the entity, if found
    #
    # @raise [Hanami::Model::UnknownPrimaryKeyError] if the table doesn't
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
      root.by_pk(id).as(:entity).one
    rescue KeyError
      raise Hanami::Model::UnknownPrimaryKeyError.new(self.class.relation)
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
      root.as(:entity).to_a
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
      root.as(:entity).first
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
      root.order(Model::Sql.desc(root.primary_key)).as(:entity).first
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
