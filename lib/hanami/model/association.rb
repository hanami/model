require 'rom-sql'
require 'hanami/model/associations/belongs_to'
require 'hanami/model/associations/has_many'
require 'hanami/model/associations/has_one'
require 'hanami/model/associations/many_to_many'

module Hanami
  module Model
    # Association factory
    #
    # @since 0.7.0
    # @api private
    class Association
      # Instantiate an association
      #
      # @since 0.7.0
      # @api private
      def self.build(repository, target, subject)
        lookup(repository.root.associations[target])
          .new(repository, repository.root.name.to_sym, target, subject)
      end

      # Translate ROM SQL associations into Hanami::Model associations
      #
      # @since 0.7.0
      # @api private
      # rubocop:disable Metrics/MethodLength
      def self.lookup(association)
        case association
        when ROM::SQL::Association::ManyToMany
          Associations::ManyToMany
        when ROM::SQL::Association::OneToOne
          Associations::HasOne
        when ROM::SQL::Association::OneToMany
          Associations::HasMany
        when ROM::SQL::Association::ManyToOne
          Associations::BelongsTo
        else
          raise "Unsupported association: #{association}"
        end
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
