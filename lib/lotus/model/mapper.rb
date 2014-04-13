require 'lotus/model/mapping/collection'

module Lotus
  module Model
    class Mapper
      def initialize(&blk)
        @collections = {}
        instance_eval(&blk) if block_given?
      end

      def collection(name, &blk)
        if block_given?
          @collections[name] = Mapping::Collection.new(name, &blk)
        else
          @collections[name] or raise Mapping::UnmappedCollectionError.new(name)
        end
      end

      # FIXME rename into identity
      def key(collection)
        collection(collection).key
      end

      # FIXME remove this indirection level
      # Let the Query to access directly the collection, instead of calling
      # this method.
      #
      # FROM
      #
      # class Sql::Query
      #   def initialize(table_name, collection, mapper, &blk)
      #     @collection = collection
      #     @table_name = table_name
      #     @mapper     = mapper
      #
      #     # ...
      #   end
      #
      #   def all
      #     @mapper.deserialize(@table_name, Lotus::Utils::Kernel.Array(run))
      #   end
      #
      #   def average(column)
      #     @mapper.deserialize_column(
      #       @table_name,
      #       column,
      #       run.avg(column)
      #     )
      #   end
      # end
      #
      # TO
      #
      # class Sql::Query
      #   def initialize(table_name, collection, mapper, &blk)
      #     @collection = collection
      #     @coercer    = mapper.collection(table_name).coercer
      #
      #     # ...
      #   end
      #
      #   def all
      #     @coercer.from_record(Lotus::Utils::Kernel.Array(run))
      #   end
      #
      #   def average(column)
      #     @coercer.public_send(:"deserialize_#{ column }", run.avg(column))
      #   end
      # end
      def serialize(collection, entity)
        collection(collection).load! # FIXME this isn't thread safe
        collection(collection).serialize(entity)
      end

      # FIXME remove this indirection level, use collection directly
      def deserialize(collection, records)
        collection(collection).load! # FIXME this isn't thread safe
        collection(collection).deserialize(records)
      end

      # FIXME remove this indirection level, use collection directly
      def deserialize_column(collection, column, value)
        collection(collection).load! # FIXME this isn't thread safe
        collection(collection).deserialize_attribute(column, value)
      end
    end
  end
end
