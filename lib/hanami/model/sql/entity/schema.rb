# frozen_string_literal: true

require "hanami/model/types"
require "hanami/model/association"

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
        # @since 0.7.0
        # @api private
        #
        # @see Hanami::Entity::Schema
        class Schema
          # Build the schema
          #
          # @param registry [Hash] a registry that keeps reference between
          #   entities class and their underscored names
          # @param relation [ROM::Relation] the database relation
          # @param mapping [Hanami::Model::Mapping] the optional repository
          #   mapping
          #
          # @return [Dry::Types::Constructor] the inner schema
          #
          # @since 2.0.0
          # @api private
          def self.build(registry, relation, mapping)
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
          # @since 2.0.0
          # @api private
          def self.build_attributes(relation, mapping)
            schema = relation.schema.to_h
            schema.each_with_object({}) do |(attribute, type), result|
              attribute = mapping.translate(attribute) if mapping.reverse?
              result[attribute] = coercible(type)
            end
          end

          # Merge attributes and associations
          #
          # @param registry [Hash] a registry that keeps reference between
          #   entities class and their underscored names
          # @param associations [ROM::AssociationSet] a set of associations for
          #   the current relation
          #
          # @return [Hash] attributes with associations
          #
          # @since 2.0.0
          # @api private
          def self.build_associations(registry, associations)
            associations.each_with_object({}) do |(name, association), result|
              target = registry.fetch(association.name)
              result[name] = Association.lookup(association).schema_type(target)
            end
          end

          # Converts given ROM type into coercible type for entity attribute
          #
          # @since 2.0.0
          # @api private
          def self.coercible(type)
            Types::Schema.coercible(type)
          end
        end
      end
    end
  end
end
