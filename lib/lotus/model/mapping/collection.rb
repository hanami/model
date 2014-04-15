require 'lotus/model/mapping/coercer'

module Lotus
  module Model
    module Mapping
      class Collection
        REPOSITORY_SUFFIX = 'Repository'.freeze

        class ::Boolean
        end

        attr_reader :name, :attributes

        def initialize(name, &blk)
          @name       = name
          @attributes = {}
          instance_eval(&blk) if block_given?
        end

        def entity(klass = nil)
          if klass
            @entity = klass
          else
            @entity
          end
        end

        def identity(name = nil)
          if name
            @identity = name
          else
            @identity || :id
          end
        end

        def attribute(name, klass, options = {})
          @attributes[name] = [klass, (options.fetch(:as) { name }).to_sym]
        end

        def serialize(entity)
          @coercer.to_record(entity)
        end

        def deserialize(records)
          records.map do |record|
            @coercer.from_record(record)
          end
        end

        def deserialize_attribute(attribute, value)
          @coercer.public_send(:"deserialize_#{ attribute }", value)
        end

        def load!
          @coercer = Coercer.new(self)
          configure_repository!
        end

        private
        def configure_repository!
          repository = Object.const_get("#{ entity.name }#{ REPOSITORY_SUFFIX }")
          repository.collection = name
        rescue NameError
        end
      end
    end
  end
end
