require 'lotus/utils/class_attribute'

module Lotus
  module Repository
    def self.included(base)
      base.class_eval do
        extend ClassMethods
        include Lotus::Utils::ClassAttribute

        # FIXME this assigment must be calculated by some Utils class
        # TODO pluralize
        class_attribute :collection
        self.collection = base.name.gsub(/Repository/, '').downcase.to_sym
      end
    end

    module ClassMethods
      def adapter=(adapter)
        @adapter = adapter
      end

      def persist(entity)
        @adapter.persist(collection, entity)
      end

      def create(entity)
        unless entity.id
          @adapter.create(collection, entity)
        end
      end

      def update(entity)
        if entity.id
          @adapter.update(collection, entity)
        else
          raise Lotus::Model::NonPersistedEntityError
        end
      end

      def delete(entity)
        if entity.id
          @adapter.delete(collection, entity)
        else
          raise Lotus::Model::NonPersistedEntityError
        end
      end

      def all
        @adapter.all(collection)
      end

      def find(id)
        @adapter.find(collection, Integer(id)).tap do |record|
          raise Lotus::Model::EntityNotFound.new unless record
        end
      end

      def first
        @adapter.first(collection)
      end

      def last
        @adapter.last(collection)
      end

      def clear
        @adapter.clear(collection)
      end
    end
  end
end
