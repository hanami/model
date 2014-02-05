module Lotus
  module Model
    module Repository
      def self.included(base)
        base.class_eval do
          extend ClassMethods
          @current_id = 0
        end
      end

      module ClassMethods
        def persist(*objects)
          objects.flatten.each do |object|
            @current_id += 1
            object.send(:id=, @current_id)
            records[@current_id] = object
          end
        end

        def all
          records.values
        end

        def find(id)
          records[id]
        end

        def first
          all.first
        end

        def last
          all.last
        end

        def clear
          records.clear
        end

        protected
        def records
          @records ||= {}
        end
      end
    end
  end
end
