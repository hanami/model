module Lotus
  module Model
    module Mapping
      #TODO check if move this into lotus/model/mapping.rb
      class UnmappedCollectionError < ::StandardError
        def initialize(name)
          super("Cannot find collection: #{ name }")
        end
      end

      class Coercer
        def initialize(collection)
          @collection = collection
          _compile!
        end

        private
        # TODO: Move these conversions into Lotus::Utils
        def Integer(value)
          # TODO benchmark:
          #   1. if value
          #   2. unless value.nil?
          Kernel.Integer(value) if value
        end

        def _compile!
          instance_eval %{
            def to_record(entity)
              Hash[*[#{ @collection.attributes.map{|name,_| ":#{name},entity.#{name}"}.join(',') }]]
            end

            def from_record(record)
              #{ @collection.entity }.new(
                Hash[*[#{ @collection.attributes.map{|name,klass| ":#{name},#{klass}(record[:#{name}])"}.join(',') }]]
              )
            end
          }
        end
      end

      class Collection
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

        def adapter(name = nil)
          if name
            @adapter = name
          else
            @adapter
          end
        end

        def attribute(name, klass)
          @attributes[name] = klass
        end

        def serialize(entity)
          @coercer.to_record(entity)
        end

        def deserialize(records)
          records.map do |record|
            @coercer.from_record(record)
          end
        end

        def load!
          @coercer = Coercer.new(self)
          configure_repository!
        end

        private
        def configure_repository!
          # TODO move this in an high level loader (eg Model.load!)
          # FIXME make this hardcoded string configurable
          repository = Object.const_get("#{ entity.name }Repository")
          repository.collection = name
        rescue NameError
        end
      end
    end
  end
end
