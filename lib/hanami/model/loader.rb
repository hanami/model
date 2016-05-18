require 'hanami/utils/string'

module Hanami
  module Model
    # Loader
    class Loader
      # @param configuration [ROM::Configuration]
      def initialize(configuration, connection)
        @configuration = configuration
        @tables        = connection.tables
      end

      def run
        for_each do |relation, mapping|
          define_relation(relation)
          define_mapping(relation, mapping)
          define_repository(relation, mapping)
        end
      end

      private

      def for_each(&blk)
        @tables.each_with_object({}) do |relation, result|
          mapping         = Utils::String.new(relation).singularize.to_sym
          result[mapping] = blk.call(relation, mapping)
        end
      end

      def define_relation(relation)
        @configuration.relation(relation) do
          def by_id(id)
            where(id: id)
          end
        end
      end

      def define_mapping(relation, mapping)
        klass = Utils::Class.load!(
          Utils::String.new(mapping).classify
        )

        @configuration.mappers do
          define(relation) do
            model       klass
            register_as mapping
          end
        end
      end

      def define_repository(relation, mapping)
        Class.new(ROM::Repository[relation]) do
          defines     :mapping
          self.mapping mapping

          commands :create, update: :by_id, delete: :by_id, mapper: mapping

          def find(id)
            collection.by_id(id).one
          end

          def all
            collection
          end

          def collection
            root.as(self.class.mapping)
          end
        end
      end
    end
  end
end
