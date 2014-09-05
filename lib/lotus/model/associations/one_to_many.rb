module Lotus
  module Model
    module Associations
      class OneToMany
        attr_reader :collection
        attr_accessor :repository

        def initialize(opts)
          @name        = opts.fetch(:name)
          @collection  = opts.fetch(:collection)
          @foreign_key = opts.fetch(:foreign_key)
          @repository  = nil
        end

        def associate_entities!(entities)
          entities.map do |entity|
            entity.send("#{@name}=", by_foreign_key(entity.id))
            entity
          end
        end

        private
        
        def by_foreign_key(key)
          @repository.send(:query).where(@foreign_key => key).to_a
        end
      end
    end
  end
end
