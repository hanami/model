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

        def persist(entity)
          @adapter.persist(entity)
        end

        def create(entity)
          @adapter.create(entity)
        end

        def update(entity)
          @adapter.update(entity)
        end

        def delete(entity)
          @adapter.delete(entity)
        end

        def all
          @adapter.all
        end

        def find(id)
          @adapter.find(id).tap do |record|
            raise RecordNotFound.new unless record
          end
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
