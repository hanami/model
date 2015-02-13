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
        # Compile itself for performance boost.
        #
        # @api private
        # @since 0.1.0
        def _compile!
          code = @collection.attributes.map do |_,(klass,mapped)|
            %{
            def deserialize_#{ mapped }(value)
              Lotus::Model::Mapping::Coercions.#{klass}(value)
            end
            }
          end.join("\n")

          instance_eval <<-EVAL, __FILE__, __LINE__
            def to_record(entity)
              if entity.id
                Hash[#{ @collection.attributes.map{|name,(klass,mapped)| ":#{mapped},Lotus::Model::Mapping::Coercions.#{klass}(entity.#{name})"}.join(',') }]
              else
                Hash[#{ @collection.attributes.reject{|name,_| name == @collection.identity }.map{|name,(klass,mapped)| ":#{mapped},Lotus::Model::Mapping::Coercions.#{klass}(entity.#{name})"}.join(',') }]
              end
            end

            def from_record(record)
              #{ @collection.entity }.new(
                Hash[#{ @collection.attributes.map{|name,(klass,mapped)| ":#{name},Lotus::Model::Mapping::Coercions.#{klass}(record[:#{mapped}])"}.join(',') }]
              )
            end

            #{ code }
          EVAL
        end
      end
    end
  end
end

