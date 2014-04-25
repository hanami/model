require 'lotus/model/mapping'

module Lotus
  module Model
    # A persistence mapper that keep entities independent from database details.
    #
    # This is database independent. It can work with SQL, document, and even
    # with key/value stores.
    #
    # @since 0.1.0
    #
    # @see http://martinfowler.com/eaaCatalog/dataMapper.html
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
      #   * #initialize(collection) # Lotus::Model::Mapping::Collection
      #   * #to_record(entity)      # translates an entity to the database type
      #   * #from_record(record)    # translates a record into an  entity
      #   * #deserialize_*(value)   # a set of methods, one for each database column.
      #
      # If not given, it uses `Lotus::Model::Mapping::Coercer`, by default.
      #
      #
      #
      # @param coercer [Class] an optional class that defines the policies for
      #   entity translations from/to the database.
      #
      # @param blk [Proc] an optional block of code that gets evaluated in the
      #   context of the current instance
      #
      # @return [Lotus::Model::Mapper]
      #
      # @since 0.1.0
      def initialize(coercer = nil, &blk)
        @coercer     = coercer || Mapping::Coercer
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
      # @see Lotus::Model::Mapping::Collection
      def collection(name, &blk)
        if block_given?
          @collections[name] = Mapping::Collection.new(name, @coercer, &blk)
        else
          # TODO implement a getter with a private API.
          @collections[name] or raise Mapping::UnmappedCollectionError.new(name)
        end
      end

      # Loads the internals of the mapper, in order to guarantee thread safety.
      #
      # This method MUST be invoked as the last thing before of start using the
      # application.
      #
      # @since 0.1.0
      def load!
        @collections.each_value {|collection| collection.load! }
        self
      end
    end
  end
end
