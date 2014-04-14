require 'lotus/utils/kernel'

module Lotus
  module Model
    module Mapping
      class Coercer
        def initialize(collection)
          @collection = collection
          _compile!
        end

        def _compile!
          code = @collection.attributes.map do |_,(klass,mapped)|
            %{
            def deserialize_#{ mapped }(value)
              Lotus::Utils::Kernel.#{klass}(value)
            end
            }
          end.join("\n")

          instance_eval %{
            def to_record(entity)
              Hash[*[#{ @collection.attributes.map{|name,(_,mapped)| ":#{mapped},entity.#{name}"}.join(',') }]]
            end

            def from_record(record)
              #{ @collection.entity }.new(
                Hash[*[#{ @collection.attributes.map{|name,(klass,mapped)| ":#{name},Lotus::Utils::Kernel.#{klass}(record[:#{mapped}])"}.join(',') }]]
              )
            end

            #{ code }
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
          self.load! # FIXME this isn't thread safe
          @coercer.to_record(entity)
        end

        def deserialize(records)
          self.load! # FIXME this isn't thread safe
          records.map do |record|
            @coercer.from_record(record)
          end
        end

        def deserialize_attribute(attribute, value)
          self.load! # FIXME this isn't thread safe
          @coercer.public_send(:"deserialize_#{ attribute }", value)
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
