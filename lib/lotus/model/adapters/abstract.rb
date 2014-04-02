module Lotus
  module Model
    module Adapters
      class Abstract
        def initialize(mapper, uri = nil)
          @mapper, @uri = mapper, uri
        end

        def persist(collection, entity)
          raise NotImplementedError
        end

        def create(collection, entity)
          raise NotImplementedError
        end

        def update(collection, entity)
          raise NotImplementedError
        end

        def delete(collection, entity)
          raise NotImplementedError
        end

        def all(collection)
          raise NotImplementedError
        end

        def find(collection, id)
          raise NotImplementedError
        end

        def first(collection)
          raise NotImplementedError
        end

        def last(collection)
          raise NotImplementedError
        end

        def clear(collection)
          raise NotImplementedError
        end
      end
    end
  end
end
