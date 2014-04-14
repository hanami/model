require 'lotus/model/adapters/abstract'
require 'lotus/model/adapters/implementation'
require 'lotus/model/adapters/sql/collection'
require 'lotus/model/adapters/sql/command'
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
          @connection.extend_datasets(Sql::Collection)
        end

        def create(collection, entity)
          entity.id = command(
                        query(collection)
                      ).create(entity)
          entity
        end

        def update(collection, entity)
          command(
            _find(collection, entity.id)
          ).update(entity)
        end

        def delete(collection, entity)
          command(
            _find(collection, entity.id)
          ).delete
        end

        def clear(collection)
          command(query(collection)).clear
        end

        def command(query)
          Sql::Command.new(query, @mapper)
        end

        def query(collection, &blk)
          Sql::Query.new(_collection(collection), @mapper, &blk)
        end

        private
        def _collection(name)
          @connection[name]
        end
      end
    end
  end
end
