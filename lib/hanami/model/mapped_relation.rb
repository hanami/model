module Hanami
  module Model
    # Mapped proxy for ROM relations.
    #
    # It eliminates the need of use #as for repository queries
    #
    # @since 1.0.0.beta1
    # @api private
    class MappedRelation < SimpleDelegator
      # Mapper name.
      #
      # With ROM mapping there is a link between the entity class and a generic
      # reference for it. Example: <tt>BookRepository</tt> references <tt>Book</tt>
      # as <tt>:entity</tt>.
      #
      # @since 1.0.0.beta1
      # @api private
      MAPPER_NAME = :entity

      # @since 1.0.0.beta1
      # @api private
      def self.mapper_name
        MAPPER_NAME
      end

      # @since 1.0.0.beta1
      # @api private
      def initialize(relation)
        super(relation.as(self.class.mapper_name))
      end
    end
  end
end
