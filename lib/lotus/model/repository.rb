module Lotus
  module Model
    module Repository
      def self.included(base)
        base.class_eval do
          base.extend ClassMethods
        end
      end

      module ClassMethods
        def persist(*objects)
          records << objects
          records.flatten!
        end

        def all
          records
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
          @records ||= []
        end
      end
    end
  end
end
