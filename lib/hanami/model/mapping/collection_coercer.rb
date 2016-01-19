module Hanami
  module Model
    module Mapping
      # Translates values from/to the database with the corresponding Ruby type.
      #
      # @api private
      # @since 0.1.0
      class CollectionCoercer
        # Initialize a coercer for the given collection.
        #
        # @param collection [Hanami::Model::Mapping::Collection] the collection
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
          code = @collection.attributes.map do |_,attr|
            %{
            def deserialize_#{ attr.mapped }(value)
              #{ attr.load_coercer }(value)
            end
            }
          end.join("\n")

          instance_eval <<-EVAL, __FILE__, __LINE__
            def to_record(entity)
              if entity.id
                Hash[#{ @collection.attributes.map{|name,attr| ":#{ attr.mapped },#{ attr.dump_coercer }(entity.#{name})"}.join(',') }]
              else
                Hash[].tap do |record|
                  #{ @collection.attributes.reject{|name,_| name == @collection.identity }.map{|name,attr| "value = #{ attr.dump_coercer }(entity.#{name}); record[:#{attr.mapped}] = value unless value.nil?"}.join('; ') }
                end
              end
            end

            def from_record(record)
              ::#{ @collection.entity }.new(
                Hash[#{ @collection.attributes.map{|name,attr| ":#{name},#{attr.load_coercer}(record[:#{attr.mapped}])"}.join(',') }]
              )
            end

            #{ code }
          EVAL
        end
      end
    end
  end
end
