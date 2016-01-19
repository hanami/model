module Hanami
  module Model
    # Abstract coercer
    #
    # It can be used as super class for custom mapping coercers.
    #
    # @since 0.5.0
    #
    # @see Hanami::Model::Mapper
    #
    # @example Postgres Array
    #   require 'hanami/model/coercer'
    #   require 'sequel/extensions/pg_array'
    #
    #   class PGArray < Hanami::Model::Coercer
    #     def self.dump(value)
    #       ::Sequel.pg_array(value) rescue nil
    #     end
    #
    #     def self.load(value)
    #       ::Kernel.Array(value) unless value.nil?
    #     end
    #   end
    #
    #   Hanami::Model.configure do
    #     mapping do
    #       collection :articles do
    #         entity     Article
    #         repository ArticleRepository
    #
    #         attribute :id,    Integer
    #         attribute :title, String
    #         attribute :tags,  PGArray
    #       end
    #     end
    #   end.load!
    #
    #   # When the entity is serialized, it calls `PGArray.dump` to store `tags`
    #   # as a Postgres Array.
    #   #
    #   # When the record is loaded (unserialized) from the database, it calls
    #   # `PGArray.load` and returns a Ruby Array.
    class Coercer
      # Deserialize (load) a value coming from the database into a Ruby object.
      #
      # When inheriting from this class, it's a good practice to return <tt>nil</tt>
      # if the given value it's <tt>nil</tt>.
      #
      # @abstract
      #
      # @raise [TypeError] if the value can't be coerced
      #
      # @since 0.5.0
      #
      # @see Hanami::Model::Mapping::Coercers
      def self.load(value)
        raise NotImplementedError
      end

      # Serialize (dump) a Ruby object into a value that can be store by the database.
      #
      # @abstract
      #
      # @raise [TypeError] if the value can't be coerced
      #
      # @since 0.5.0
      #
      # @see Hanami::Model::Mapping::Coercers
      def self.dump(value)
        self.load(value)
      end
    end
  end
end
