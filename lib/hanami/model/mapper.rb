require 'hanami/model/mapping'

module Hanami
  module Model
    # Error for missing mapper
    # It's raised when loading model without mapper
    #
    # @since 0.2.0
    #
    # @see Hanami::Model::Configuration#mapping
    class NoMappingError < Hanami::Model::Error
      def initialize
        super("Mapping is missing. Please check your framework configuration.")
      end
    end

    # @since 0.2.0
    # @api private
    class NullMapper
      def method_missing(m, *args)
        raise NoMappingError.new
      end
    end

    # A persistence mapper that keeps entities independent from database details.
    #
    # This is database independent. It can work with SQL, document, and even
    # with key/value stores.
    #
    # @since 0.1.0
    #
    # @see http://martinfowler.com/eaaCatalog/dataMapper.html
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
    #
    #   # This guarantees thread-safety and should happen as last thing before
    #   # to start the app code.
    #   mapper.load!
    class Mapper
      # @attr_reader collections [Hash] all the mapped collections
      #
      # @since 0.1.0
      # @api private
      attr_reader :collections

      # Instantiate a mapper.
      #
      # It accepts an optional argument (`coercer`) a class that defines the
      # policies for entities translations from/to the database.
      #
      # If provided, this class must implement the following interface:
      #
      #   * #initialize(collection) # Hanami::Model::Mapping::Collection
      #   * #to_record(entity)      # translates an entity to the database type
      #   * #from_record(record)    # translates a record into an entity
      #   * #deserialize_*(value)   # a set of methods, one for each database column.
      #
      # If not given, it uses `Hanami::Model::Mapping::CollectionCoercer`, by default.
      #
      #
      #
      # @param coercer [Class] an optional class that defines the policies for
      #   entity translations from/to the database.
      #
      # @param blk [Proc] an optional block of code that gets evaluated in the
      #   context of the current instance
      #
      # @return [Hanami::Model::Mapper]
      #
      # @since 0.1.0
      def initialize(coercer = nil, &blk)
        @coercer     = coercer || Mapping::CollectionCoercer
        @collections = {}

        instance_eval(&blk) if block_given?
      end

      # Maps a collection.
      #
      # A collection is a set of homogeneous records. Think of a table of a SQL
      # database or about collection of MongoDB.
      #
      # @param name [Symbol] the name of the mapped collection. If used with a
      #   SQL database it's the table name.
      #
      # @param blk [Proc] the block that maps the attributes of that collection.
      #
      # @since 0.1.0
      #
      # @see Hanami::Model::Mapping::Collection
      def collection(name, &blk)
        if block_given?
          @collections[name] = Mapping::Collection.new(name, @coercer, &blk)
        else
          @collections[name] or raise Mapping::UnmappedCollectionError.new(name)
        end
      end

      # Loads the internals of the mapper, in order to guarantee thread safety.
      #
      # This method MUST be invoked as the last thing before of start using the
      # application.
      #
      # @since 0.1.0
      def load!(adapter = nil)
        @collections.each_value do |collection|
          collection.adapter = adapter
          collection.load!
        end
        self
      end
    end
  end
end
