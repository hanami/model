require 'hanami/utils/class'
require 'hanami/model/mapping/attribute'

module Hanami
  module Model
    module Mapping
      # Maps a collection and its attributes.
      #
      # A collection is a set of homogeneous records. Think of a table of a SQL
      # database or about collection of MongoDB.
      #
      # This is database independent. It can work with SQL, document, and even
      # with key/value stores.
      #
      # @since 0.1.0
      #
      # @see Hanami::Model::Mapper
      #
      # @example
      #   require 'hanami/model'
      #
      #   mapper = Hanami::Model::Mapper.new do
      #     collection :users do
      #       entity User
      #
      #       attribute :id,   Integer
      #       attribute :name, String
      #     end
      #   end
      class Collection
        # Repository name suffix
        #
        # @api private
        # @since 0.1.0
        #
        # @see Hanami::Repository
        REPOSITORY_SUFFIX = 'Repository'.freeze

        # @attr_reader name [Symbol] the name of the collection
        #
        # @since 0.1.0
        # @api private
        attr_reader :name

        # @attr_reader coercer_class [Class] the coercer class
        #
        # @since 0.1.0
        # @api private
        attr_reader :coercer_class

        # @attr_reader attributes [Hash] the set of attributes
        #
        # @since 0.1.0
        # @api private
        attr_reader :attributes

        # @attr_reader adapter [Hanami::Model::Adapters] the instance of adapter
        #
        # @since 0.1.0
        # @api private
        attr_accessor :adapter

        # Instantiate a new collection
        #
        # @param name [Symbol] the name of the mapped collection. If used with a
        #   SQL database it's the table name.
        #
        # @param coercer_class [Class] the coercer class
        # @param blk [Proc] the block that maps the attributes of that collection.
        #
        # @since 0.1.0
        #
        # @see Hanami::Model::Mapper#collection
        def initialize(name, coercer_class, &blk)
          @name = name
          @coercer_class = coercer_class
          @attributes = {}
          instance_eval(&blk) if block_given?
        end

        # Defines the entity that is persisted with this collection.
        #
        # The entity can be any kind of object as long as it implements the
        # following interface: `#initialize(attributes = {})`.
        #
        # @param klass [Class, String] the entity persisted with this collection.
        #
        # @since 0.1.0
        #
        # @see Hanami::Entity
        #
        # @example Set entity with class name
        #   require 'hanami/model'
        #
        #   mapper = Hanami::Model::Mapper.new do
        #     collection :articles do
        #       entity Article
        #     end
        #   end
        #
        #   mapper.entity #=> Article
        #
        # @example Set entity with class name string
        #   require 'hanami/model'
        #
        #   mapper = Hanami::Model::Mapper.new do
        #     collection :articles do
        #       entity 'Article'
        #     end
        #   end
        #
        #   mapper.entity #=> Article
        #
        def entity(klass = nil)
          if klass
            @entity = klass
          else
            @entity
          end
        end

        # Defines the repository that interacts with this collection.
        #
        # @param klass [Class, String] the repository that interacts with this collection.
        #
        # @since 0.2.0
        #
        # @see Hanami::Repository
        #
        # @example Set repository with class name
        #   require 'hanami/model'
        #
        #   mapper = Hanami::Model::Mapper.new do
        #     collection :articles do
        #       entity Article
        #
        #       repository RemoteArticleRepository
        #     end
        #   end
        #
        #   mapper.repository #=> RemoteArticleRepository
        #
        # @example Set repository with class name string
        #   require 'hanami/model'
        #
        #   mapper = Hanami::Model::Mapper.new do
        #     collection :articles do
        #       entity Article
        #
        #       repository 'RemoteArticleRepository'
        #     end
        #   end
        #
        #   mapper.repository #=> RemoteArticleRepository
        def repository(klass = nil)
          if klass
            @repository = klass
          else
            @repository ||= default_repository_klass
          end
        end

        # Defines the identity for a collection.
        #
        # An identity is a unique value that identifies a record.
        # If used with an SQL table it corresponds to the primary key.
        #
        # This is an optional feature.
        # By default the system assumes that your identity is `:id`.
        # If this is the case, you can omit the value, otherwise you have to
        # specify it.
        #
        # @param name [Symbol] the name of the identity
        #
        # @since 0.1.0
        #
        # @example Default
        #   require 'hanami/model'
        #
        #   # We have an SQL table `users` with a primary key `id`.
        #   #
        #   # This this is compliant to the mapper default, we can omit
        #   # `#identity`.
        #
        #   mapper = Hanami::Model::Mapper.new do
        #     collection :users do
        #       entity User
        #
        #       # attribute definitions..
        #     end
        #   end
        #
        # @example Custom identity
        #   require 'hanami/model'
        #
        #   # We have an SQL table `articles` with a primary key `i_id`.
        #   #
        #   # This schema diverges from the expected default: `id`, that's why
        #   # we need to use #identity to let the mapper to recognize the
        #   # primary key.
        #
        #   mapper = Hanami::Model::Mapper.new do
        #     collection :articles do
        #       entity Article
        #
        #       # attribute definitions..
        #
        #       identity :i_id
        #     end
        #   end
        def identity(name = nil)
          if name
            @identity = name
          else
            @identity || :id
          end
        end

        # Map an attribute.
        #
        # An attribute defines a property of an object.
        # This is storage independent. For instance, it can map an SQL column,
        # a MongoDB attribute or everything that makes sense for your database.
        #
        # Each attribute defines a Ruby type, to coerce that value from the
        # database. This fixes a huge problem, because database types don't
        # match Ruby types.
        # Think of Redis, where everything is stored as a string or integer,
        # the mapper translates values from/to the database.
        #
        # It supports the following types (coercers):
        #
        #   * Array
        #   * Boolean
        #   * Date
        #   * DateTime
        #   * Float
        #   * Hash
        #   * Integer
        #   * BigDecimal
        #   * Set
        #   * String
        #   * Symbol
        #   * Time
        #
        # @param name [Symbol] the name of the attribute, as we want it to be
        #   mapped in the object
        #
        # @param coercer [.load, .dump] a class that implements coercer interface
        #
        # @param options [Hash] a set of options to customize the mapping
        # @option options [Symbol] :as the name of the original column
        #
        # @raise [NameError] if coercer cannot be found
        #
        # @since 0.1.0
        #
        # @see Hanami::Model::Coercer
        #
        # @example Default schema
        #   require 'hanami/model'
        #
        #   # Given the following schema:
        #   #
        #   # CREATE TABLE users (
        #   #   id     integer NOT NULL,
        #   #   name   varchar(64),
        #   # );
        #   #
        #   # And the following entity:
        #   #
        #   # class User
        #   #   include Hanami::Entity
        #   #   attributes :name
        #   # end
        #
        #   mapper = Hanami::Model::Mapper.new do
        #     collection :users do
        #       entity User
        #
        #       attribute :id,   Integer
        #       attribute :name, String
        #     end
        #   end
        #
        #   # The first argument (`:name`) always corresponds to the `User`
        #   # attribute.
        #
        #   # The second one (`:coercer`) is the Ruby type coercer that we want
        #   # for our attribute.
        #
        #   # We don't need to use `:as` because the database columns match the
        #   # `User` attributes.
        #
        # @example Customized schema
        #   require 'hanami/model'
        #
        #   # Given the following schema:
        #   #
        #   # CREATE TABLE articles (
        #   #   i_id           integer NOT NULL,
        #   #   i_user_id      integer NOT NULL,
        #   #   s_title        varchar(64),
        #   #   comments_count varchar(8) # Not an error: it's for String => Integer coercion
        #   # );
        #   #
        #   # And the following entity:
        #   #
        #   # class Article
        #   #   include Hanami::Entity
        #   #   attributes :user_id, :title, :comments_count
        #   # end
        #
        #   mapper = Hanami::Model::Mapper.new do
        #     collection :articles do
        #       entity Article
        #
        #       attribute :id,             Integer, as: :i_id
        #       attribute :user_id,        Integer, as: :i_user_id
        #       attribute :title,          String,  as: :s_title
        #       attribute :comments_count, Integer
        #
        #       identity :i_id
        #     end
        #   end
        #
        #   # The first argument (`:name`) always corresponds to the `Article`
        #   # attribute.
        #
        #   # The second one (`:coercer`) is the Ruby type that we want for our
        #   # attribute.
        #
        #   # The third option (`:as`) is mandatory only when the database
        #   # column doesn't match the name of the mapped attribute.
        #   #
        #   # For instance: we need to use it for translate `:s_title` to
        #   # `:title`, but not for `:comments_count`.
        #
        # @example Custom coercer
        #   require 'hanami/model'
        #
        #   # Given the following schema:
        #   #
        #   # CREATE TABLE articles (
        #   #   id     integer NOT NULL,
        #   #   title  varchar(128),
        #   #   tags   text[],
        #   # );
        #   #
        #   # The following entity:
        #   #
        #   # class Article
        #   #   include Hanami::Entity
        #   #   attributes :title, :tags
        #   # end
        #   #
        #   # And the following custom coercer:
        #   #
        #   # require 'hanami/model/coercer'
        #   # require 'sequel/extensions/pg_array'
        #   #
        #   # class PGArray < Hanami::Model::Coercer
        #   #   def self.dump(value)
        #   #     ::Sequel.pg_array(value) rescue nil
        #   #   end
        #   #
        #   #   def self.load(value)
        #   #     ::Kernel.Array(value) unless value.nil?
        #   #   end
        #   # end
        #
        #   mapper = Hanami::Model::Mapper.new do
        #     collection :articles do
        #       entity Article
        #
        #       attribute :id,    Integer
        #       attribute :title, String
        #       attribute :tags,  PGArray
        #     end
        #   end
        #
        #   # When an entity is persisted as record into the database,
        #   # `PGArray.dump` is invoked.
        #
        #   # When an entity is retrieved from the database, it will be
        #   # deserialized as an Array via `PGArray.load`.
        def attribute(name, coercer, options = {})
          @attributes[name] = Attribute.new(name, coercer, options)
        end

        # Serializes an entity to be persisted in the database.
        #
        # @param entity [Object] an entity
        #
        # @api private
        # @since 0.1.0
        def serialize(entity)
          @coercer.to_record(entity)
        end

        # Deserialize a set of records fetched from the database.
        #
        # @param records [Array] a set of raw records
        #
        # @api private
        # @since 0.1.0
        def deserialize(records)
          records.map do |record|
            @coercer.from_record(record)
          end
        end

        # Deserialize only one attribute from a raw value.
        #
        # @param attribute [Symbol] the attribute name
        # @param value [Object,nil] the value to be coerced
        #
        # @api private
        # @since 0.1.0
        def deserialize_attribute(attribute, value)
          @coercer.public_send(:"deserialize_#{ attribute }", value)
        end

        # Loads the internals of the mapper, in order to guarantee thread safety.
        #
        # @api private
        # @since 0.1.0
        def load!
          _load_entity!
          _load_repository!
          _load_coercer!

          _configure_repository!
        end

        private

        # Assigns a repository to an entity
        #
        # @see Hanami::Repository
        #
        # @api private
        # @since 0.1.0
        def _configure_repository!
          repository.collection = name
          repository.adapter = adapter if adapter
        end

        # Convert repository string to repository class
        #
        # @api private
        # @since 0.2.0
        def _load_repository!
          @repository = Utils::Class.load!(repository)
        rescue NameError
          raise Hanami::Model::Mapping::RepositoryNotFound.new(repository.to_s)
        end

        # Convert entity string to entity class
        #
        # @api private
        # @since 0.2.0
        def _load_entity!
          @entity = Utils::Class.load!(entity)
        rescue NameError
          raise Hanami::Model::Mapping::EntityNotFound.new(entity.to_s)
        end

        # Load coercer
        #
        # @api private
        # @since 0.1.0
        def _load_coercer!
          @coercer = coercer_class.new(self)
        end

        # Retrieves the default repository class
        #
        # @see Hanami::Repository
        #
        # @api private
        # @since 0.2.0
        def default_repository_klass
          "#{ entity }#{ REPOSITORY_SUFFIX }"
        end

      end
    end
  end
end
