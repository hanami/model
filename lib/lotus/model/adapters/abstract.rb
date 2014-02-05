module Lotus
  module Model
    module Adapters
      class Abstract
        def persist(object)
          raise NotImplementedError
        end

        def create(object)
          raise NotImplementedError
        end

        def update(object)
          raise NotImplementedError
        end

        def delete(object)
          raise NotImplementedError
        end

        def all
          raise NotImplementedError
        end

        def find(id)
          raise NotImplementedError
        end

        def first
          raise NotImplementedError
        end

        def last
          raise NotImplementedError
        end

        def clear
          raise NotImplementedError
        end
      end
    end
  end
end
