require 'lotus/utils/kernel'

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
        include Lotus::Utils::Kernel

        def initialize(collection)
          @collection = collection
          _compile!
        end

        def _compile!
          instance_eval %{
            def to_record(entity)
              Hash[*[#{ @collection.attributes.map{|name,(_,mapped)| ":#{mapped},entity.#{name}"}.join(',') }]]
            end

            def from_record(record)
              #{ @collection.entity }.new(
                Hash[*[#{ @collection.attributes.map{|name,(klass,mapped)| ":#{name},#{klass}(record[:#{mapped}])"}.join(',') }]]
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

        def key(name = nil)
          if name
            @key = name
          else
            @key || :id
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
