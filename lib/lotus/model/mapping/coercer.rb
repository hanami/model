require 'lotus/model/mapping/coercer'

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
          if entity.id
            Hash[
              @collection.attributes.map {|name,(_,mapped)|
                [mapped, entity.__send__(name)]
              }
            ]
          else
            Hash[
              @collection.attributes.reject {|name,_| name == @collection.identity }.map{|name,(_,mapped)|
                [mapped, entity.__send__(name)]
              }
            ]
          end
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
          @collection.entity.new(
            Hash[
              @collection.attributes.map { |name, (klass,mapped)|
                [name, Lotus::Model::Mapping::Coercions.coerce(klass, record[mapped])]
              }
            ]
          )
        end

        private
        # Compile itself for performance boost.
        #
        # @api private
        # @since 0.1.0
        def _compile!
          instance_eval(
            @collection.attributes.map do |_,(klass,mapped)|
              %{
              def deserialize_#{ mapped }(value)
                Lotus::Model::Mapping::Coercions.#{klass}(value)
              end
              }
            end.join("\n")
          )
        end
      end
    end
  end
end

