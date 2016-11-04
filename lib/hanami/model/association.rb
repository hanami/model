require 'rom-sql'
require 'hanami/model/associations/has_many'
require 'hanami/model/associations/belongs_to'

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
        lookup(repository.root.associations[target])
          .new(repository, repository.root.name.to_sym, target, subject)
      end

      # Translate ROM SQL associations into Hanami::Model associations
      #
      # @since x.x.x
      # @api private
      def self.lookup(association)
        case association
        when ROM::SQL::Association::OneToMany
          Associations::HasMany
        when ROM::SQL::Association::ManyToOne
          Associations::BelongsTo
        else
          raise "Unsupported association: #{association}"
        end
      end
    end
  end
end
