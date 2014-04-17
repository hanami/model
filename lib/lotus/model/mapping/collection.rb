module Lotus
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
      # @see Lotus::Model::Mapper
      #
      # @example
      #   require 'lotus/model'
      #
      #   mapper = Lotus::Model::Mapper.new do
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
        # @see Lotus::Repository
        REPOSITORY_SUFFIX = 'Repository'.freeze

        # Defines top level constant for attribute usage.
        #
        # @since 0.1.0
        #
        # @see Lotus::Model::Mapping::Collection#attribute
        #
        # @example
        #   require 'lotus/model'
        #
        #   mapper = Lotus::Model::Mapper.new do
        #     collection :articles do
        #       entity Article
        #
        #       attribute :published, Boolean
        #     end
        #   end
        class ::Boolean
        end

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

        # Instantiate a new collection
        #
        # @param name [Symbol] the name of the mapped collection. If used with a
        #   SQL database it's the table name.
        #
        # @param blk [Proc] the block that maps the attributes of that collection.
        #
        # @since 0.1.0
        #
        # @see Lotus::Model::Mapper#collection
        def initialize(name, coercer_class, &blk)
          @name, @coercer_class, @attributes = name, coercer_class, {}
          instance_eval(&blk) if block_given?
        end

        # Defines the entity that is persisted with this collection.
        #
        # The entity can be any kind of object as long it implements the
        # following interface: `#initialize(attributes = {})`.
        #
        # @param klass [Class] the entity persisted with this collection.
        #
        # @since 0.1.0
        #
        # @see Lotus::Entity
        def entity(klass = nil)
          if klass
            @entity = klass
          else
            @entity
          end
        end

        # Defines the identity for a collection.
        #
        # An identity is an unique value that identifies a record.
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
        #   require 'lotus/model'
        #
        #   # We have an SQL table `users` with a primary key `id`.
        #   #
        #   # This this is compliant to the mapper default, we can omit
        #   # `#identity`.
        #
        #   mapper = Lotus::Model::Mapper.new do
        #     collection :users do
        #       entity User
        #
        #       # attribute definitions..
        #     end
        #   end
        #
        # @example Custom identity
        #   require 'lotus/model'
        #
        #   # We have an SQL table `articles` with a primary key `i_id`.
        #   #
        #   # This schema diverges from the expected default: `id`, that's why
        #   # we need to use #identity to let the mapper to recognize the
        #   # primary key.
        #
        #   mapper = Lotus::Model::Mapper.new do
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
        # Each attribute defines an Ruby type, to coerce that value from the
        # database. This fixes a huge problem, because database types don't
        # match Ruby types.
        # Think of Redis, where everything is stored as a string or integer,
        # the mapper translates values from/to the database.
        #
        # It supports the following types:
        #
        #   * Array
        #   * Boolean
        #   * Date
        #   * DateTime
        #   * Float
        #   * Hash
        #   * Integer
        #   * Set
        #   * String
        #   * Time
        #
        # @param name [Symbol] the name of the attribute, as we want it to be
        #   mapped in the object
        #
        # @param klass [Class] the Ruby type that we want to assign as value
        #
        # @param options [Hash] a set of options to customize the mapping
        # @option options [Symbol] :as the name of the original column
        #
        # @since 0.1.0
        #
        # @example Default schema
        #   require 'lotus/model'
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
        #   #   include Lotus::Entity
        #   #   self.attributes = :name
        #   # end
        #
        #   mapper = Lotus::Model::Mapper.new do
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
        #   # The second one (`:klass`) is the Ruby type that we want for our
        #   # attribute.
        #
        #   # We don't need to use `:as` because the database columns match the
        #   # `User` attributes.
        #
        # @example Customized schema
        #   require 'lotus/model'
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
        #   #   include Lotus::Entity
        #   #   self.attributes = :user_id, :title, :comments_count
        #   # end
        #
        #   mapper = Lotus::Model::Mapper.new do
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
        #   # The second one (`:klass`) is the Ruby type that we want for our
        #   # attribute.
        #
        #   # The third option (`:as`) is mandatory only when the database
        #   # column doesn't match the name of the mapped attribute.
        #   #
        #   # For instance: we need to use it for translate `:s_title` to
        #   # `:title`, but not for `:comments_count`.
        def attribute(name, klass, options = {})
          @attributes[name] = [klass, (options.fetch(:as) { name }).to_sym]
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
          @coercer = coercer_class.new(self)
          configure_repository!
        end

        private
        # Assigns a repository to an entity
        #
        # @see Lotus::Repository
        #
        # @api private
        # @since 0.1.0
        def configure_repository!
          repository = Object.const_get("#{ entity.name }#{ REPOSITORY_SUFFIX }")
          repository.collection = name
        rescue NameError
        end
      end
    end
  end
end
