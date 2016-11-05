require 'hanami/entity/schema'
require 'hanami/model/types'
require 'hanami/model/association'

module Hanami
  module Model
    module Sql
      module Entity
        # SQL Entity schema
        #
        # This schema setup is automatic.
        #
        # Hanami looks at the database columns, associations and potentially to
        # the mapping in the repository (optional, only for legacy databases).
        #
        # @since x.x.x
        # @api private
        #
        # @see Hanami::Entity::Schema
        class Schema < Hanami::Entity::Schema
          # Build a new instance of Schema according to database columns,
          # associations and potentially to mapping defined by the repository.
          #
          # @param registry [Hash] a registry that keeps reference between
          #   entities klass and their underscored names
          # @param relation [ROM::Relation] the database relation
          # @param mapping [Hanami::Model::Mapping] the optional repository
          #   mapping
          #
          # @return [Hanami::Model::Sql::Entity::Schema] the schema
          #
          # @since x.x.x
          # @api private
          def initialize(registry, relation, mapping)
            attributes  = build(registry, relation, mapping)
            @schema     = Types::Coercible::Hash.schema(attributes)
            @attributes = Hash[attributes.map { |k, _| [k, true] }]
            freeze
          end

          # Check if the attribute is known
          #
          # @param name [Symbol] the attribute name
          #
          # @return [TrueClass,FalseClass] the result of the check
          #
          # @since x.x.x
          # @api private
          def attribute?(name)
            attributes.key?(name)
          end

          private

          # @since x.x.x
          # @api private
          attr_reader :attributes

          # Build the schema
          #
          # @param registry [Hash] a registry that keeps reference between
          #   entities klass and their underscored names
          # @param relation [ROM::Relation] the database relation
          # @param mapping [Hanami::Model::Mapping] the optional repository
          #   mapping
          #
          # @return [Dry::Types::Constructor] the inner schema
          #
          # @since x.x.x
          # @api private
          def build(registry, relation, mapping)
            build_attributes(relation, mapping).merge(
              build_associations(registry, relation.associations)
            )
          end

          # Extract a set of attributes from the database table or from the
          # optional repository mapping.
          #
          # @param relation [ROM::Relation] the database relation
          # @param mapping [Hanami::Model::Mapping] the optional repository
          #   mapping
          #
          # @return [Hash] a set of attributes
          #
          # @since x.x.x
          # @api private
          def build_attributes(relation, mapping)
            schema = relation.schema.to_h
            return schema unless mapping.reverse?

            schema.each_with_object({}) do |(attribute, type), result|
              result[mapping.translate(attribute)] = type
            end
          end

          # Merge attributes and associations
          #
          # @param registry [Hash] a registry that keeps reference between
          #   entities klass and their underscored names
          # @param associations [ROM::AssociationSet] a set of associations for
          #   the current relation
          #
          # @return [Hash] attributes with associations
          #
          # @since x.x.x
          # @api private
          def build_associations(registry, associations)
            associations.each_with_object({}) do |(name, association), result|
              target       = registry.fetch(name)
              result[name] = Association.lookup(association).schema_type(target)
            end
          end
        end
      end
    end
  end
end
