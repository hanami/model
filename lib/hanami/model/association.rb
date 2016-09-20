require 'rom-sql'
require 'hanami/model/associations/has_many'

module Hanami
  module Model
    # Association factory
    #
    # @since x.x.x
    # @api private
    class Association
      # Instantiate an association
      #
      # @since x.x.x
      # @api private
      def self.build(repository, target, subject)
        case repository.root.associations[target]
        when ROM::SQL::Association::OneToMany then Associations::HasMany
        else
          raise 'unsupported association'
        end.new(repository, repository.root.name.to_sym, target, subject)
      end
    end
  end
end
