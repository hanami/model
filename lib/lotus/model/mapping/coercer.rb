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
    end
  end
end

