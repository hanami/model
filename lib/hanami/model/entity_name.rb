module Hanami
  module Model
    # Conventional name for entities.
    #
    # Given a repository named <tt>SourceFileRepository</tt>, the associated
    # entity will be <tt>SourceFile</tt>.
    #
    # @since 0.7.0
    # @api private
    class EntityName
      # @since 0.7.0
      # @api private
      SUFFIX = /Repository\z/

      # @param name [Class,String] the class or its name
      # @return [String] the entity name
      #
      # @since 0.7.0
      # @api private
      def initialize(name)
        @name = name.sub(SUFFIX, '')
      end

      # @since 0.7.0
      # @api private
      def underscore
        Utils::String.new(@name).underscore.to_sym
      end

      def to_s
        @name
      end
    end
  end
end
