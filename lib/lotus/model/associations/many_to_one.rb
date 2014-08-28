module Lotus
  module Model
    module Associations
      class ManyToOne
        attr_reader :collection
        attr_accessor :repository

        def initialize(opts)
          @name        = opts.fetch(:name)
          @collection  = opts.fetch(:collection)
          @foreign_key = opts.fetch(:foreign_key) {default_foreign_key}
          @repository  = nil
        end

        def associate_entities!(entities)
          entities.map do |entity|
            entity.send("#{@name}=", @repository.find(entity.send(@foreign_key)))
            entity
          end
        end

        private

        def default_foreign_key
          "#{@name}_id"
        end
      end
    end
  end
end
