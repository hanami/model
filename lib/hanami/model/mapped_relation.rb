module Hanami
  module Model
    # Mapped proxy for ROM relations.
    #
    # It eliminates the need of use #as for repository queries
    #
    # @since x.x.x
    # @api private
    class MappedRelation < SimpleDelegator
      # Mapper name.
      #
      # With ROM mapping there is a link between the entity class and a generic
      # reference for it. Example: <tt>BookRepository</tt> references <tt>Book</tt>
      # as <tt>:entity</tt>.
      #
      # @since x.x.x
      # @api private
      MAPPER_NAME = :entity

      # @since x.x.x
      # @api private
      def self.mapper_name
        MAPPER_NAME
      end

      # @since x.x.x
      # @api private
      attr_reader :unmapped

      # @since x.x.x
      # @api private
      def initialize(relation)
        @unmapped = relation
        super(unmapped.as(self.class.mapper_name))
      end
    end
  end
end
