module Lotus
  module Model
    module Repository
      def self.included(base)
        base.class_eval do
          extend ClassMethods
        end
      end

      module ClassMethods
        def adapter=(adapter)
          @adapter = adapter
        end

        def persist(object)
          @adapter.persist(object)
        end

        def create(object)
          @adapter.create(object)
        end

        def update(object)
          @adapter.update(object)
        end

        def delete(object)
          @adapter.delete(object)
        end

        def all
          @adapter.all
        end

        def find(id)
          @adapter.find(id)
        end

        def first
          @adapter.first
        end

        def last
          @adapter.last
        end

        def clear
          @adapter.clear
        end
      end
    end
  end
end
