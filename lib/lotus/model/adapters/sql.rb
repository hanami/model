require 'lotus/model/adapters/abstract'
require 'lotus/model/adapters/implementation'
require 'sequel'

module Lotus
  module Model
    module Adapters
      class Sql < Abstract
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

        def all(collection)
          _deserialize(collection, super)
        end

        def find(collection, id)
          _deserialize(
             collection,
            _collection(collection)
              .where(
                _key(collection) => id
              ).first
          ).first
        end

        def first(collection)
          _deserialize(collection, super).first
        end

        def last(collection)
          _deserialize(
             collection,
            _collection(collection)
              .order(
                _key(collection)
              ).last
          ).first
        end

        def clear(collection)
          _collection(collection).delete
        end

        private
        def _collection(name)
          @connection[name]
        end
      end
    end
  end
end
