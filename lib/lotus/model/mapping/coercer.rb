require 'lotus/utils/kernel'

module Lotus
  module Model
    module Mapping
      # Translates values from/to the database with the corresponding Ruby type.
      #
      # @api private
      # @since 0.1.0
      class Coercer
        # Initialize a coercer for the given collection.
        #
        # @param collection [Lotus::Model::Mapping::Collection] the collection
        #
        # @api private
        # @since 0.1.0
        def initialize(collection)
          @collection = collection
          _compile!
        end

        # Translates the given entity into a format compatible with the database.
        #
        # @param entity [Object] the entity
        #
        # @return [Hash]
        #
        # @api private
        # @since 0.1.0
        def to_record(entity)
        end

        # Translates the given record into a Ruby object.
        #
        # @param record [Hash]
        #
        # @return [Object]
        #
        # @api private
        # @since 0.1.0
        def from_record(record)
        end

        private
        # Compile itself for perfomance boost.
        #
        # @api private
        # @since 0.1.0
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
              if entity.id
                Hash[*[#{ @collection.attributes.map{|name,(_,mapped)| ":#{mapped},entity.#{name}"}.join(',') }]]
              else
                Hash[*[#{ @collection.attributes.reject{|name,_| name == @collection.identity }.map{|name,(_,mapped)| ":#{mapped},entity.#{name}"}.join(',') }]]
              end
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

