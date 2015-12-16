module Lotus
  module Model
    module Mapping
      # Translates values from/to the database with the corresponding Ruby type.
      #
      # @api private
      # @since 0.1.0
      class CollectionCoercer
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
          code = ''
          hash = ''
          taped_hash = ''
          from_record = ''

          @collection.attributes.each do |name, attr|
            code << %{
              def deserialize_#{attr.mapped}(value)
                #{attr.load_coercer}(value)
              end
            }

            hash << ":#{attr.mapped},#{attr.dump_coercer}(entity.#{name}),"
            from_record << ":#{name},#{attr.load_coercer}(record[:#{attr.mapped}]),"

            unless name == @collection.identity
              taped_hash << "value = #{attr.dump_coercer}(entity.#{name}); record[:#{attr.mapped}] = value unless value.nil?;"
            end
          end

          instance_eval <<-EVAL, __FILE__, __LINE__
            def to_record(entity)
              if entity.id
                Hash[#{hash}]
              else
                Hash[].tap do |record|
                  #{taped_hash}
                end
              end
            end

            def from_record(record)
              ::#{@collection.entity}.new(Hash[#{from_record}])
            end
            #{code}
          EVAL
        end
      end
    end
  end
end
