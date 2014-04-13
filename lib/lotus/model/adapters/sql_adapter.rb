require 'lotus/model/adapters/abstract'
require 'lotus/model/adapters/implementation'
require 'lotus/model/adapters/sql/query'
require 'sequel'

module Lotus
  module Model
    module Adapters
      class SqlAdapter < Abstract
        include Implementation

        def initialize(mapper, uri)
          super
          @connection = Sequel.connect(@uri)
        end

        def create(collection, entity)
          entity.id = _collection(collection)
                        .insert(
                          _serialize(collection, entity)
                        )
          entity
        end

        def update(collection, entity)
          _collection(collection)
            .where(
              _key(collection) => entity.id
            ).update(
              _serialize(collection, entity)
            )
        end

        def delete(collection, entity)
          _collection(collection)
            .where(
              _key(collection) => entity.id
            ).delete
        end

        def clear(collection)
          _collection(collection).delete
        end

        def query(collection, &blk)
          _query.new(collection, _collection(collection), @mapper, &blk)
        end

        private
        def _collection(name)
          # FIXME wrap the collection, so that Sql::Query and Memory::Query
          # #initialize can have the same signature.
          #
          # class Sql::Collection < Sequel::Dataset
          #   def initialize(*args)
          #     super(*args)
          #     @name = name
          #   end
          # end
          #
          # And use it:
          #
          # Sequel.dataset_class = Sql::Collection
          @connection[name]
        end

        def _query
          # FIXME Dependency injection
          Sql::Query
        end
      end
    end
  end
end
