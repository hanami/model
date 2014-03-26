module Lotus
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
        unless entity.id
          @adapter.create(entity)
        end
      end

      def update(entity)
        if entity.id
          @adapter.update(entity)
        else
          raise Lotus::Model::NonPersistedEntityError
        end
      end

      def delete(entity)
        if entity.id
          @adapter.delete(entity)
        else
          raise Lotus::Model::NonPersistedEntityError
        end
      end

      def all
        @adapter.all
      end

      def find(id)
        @adapter.find(Integer(id)).tap do |record|
          raise Lotus::Model::EntityNotFound.new unless record
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
