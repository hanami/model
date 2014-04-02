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

      def serialize(collection, entity)
        collection(collection).load! # FIXME this isn't thread safe
        collection(collection).serialize(entity)
      end

      def deserialize(collection, records)
        collection(collection).load! # FIXME this isn't thread safe
        collection(collection).deserialize(records)
      end
    end
  end
end
