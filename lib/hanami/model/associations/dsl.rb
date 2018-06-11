# frozen_string_literal: true

module Hanami
  module Model
    module Associations
      # Auto-infer relations linked to repository's associations
      #
      # @since 0.7.0
      # @api private
      #
      # rubocop:disable Naming/PredicateName
      class Dsl
        # @since 0.7.0
        # @api private
        def initialize(repository, &blk)
          @repository = repository
          instance_eval(&blk)
        end

        # @since 0.7.0
        # @api private
        def has_many(relation, *)
        end

        # @since 1.1.0
        # @api private
        def has_one(relation, *)
          # @repository.__send__(:relations, inflector.pluralize(relation).to_sym)
        end

        # @since 1.1.0
        # @api private
        def belongs_to(relation, *)
          # @repository.__send__(:relations, inflector.pluralize(relation).to_sym)
        end

        private

        # @since x.x.x
        # @api private
        def inflector
          Model.configuration.inflector
        end
      end
      # rubocop:enable Naming/PredicateName
    end
  end
end
