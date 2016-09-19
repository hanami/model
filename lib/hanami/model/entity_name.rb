module Hanami
  module Model
    # Conventional name for entities.
    #
    # Given a repository named <tt>SourceFileRepository</tt>, the associated
    # entity will be <tt>SourceFile</tt>.
    #
    # @since x.x.x
    # @api private
    class EntityName
      # @since x.x.x
      # @api private
      SUFFIX = /Repository\z/

      # @param name [Class,String] the class or its name
      # @return [String] the entity name
      #
      # @since x.x.x
      # @api private
      def self.new(name)
        name.sub(SUFFIX, '')
      end
    end
  end
end
