# frozen_string_literal: true

require "rom-sql"
require "rom/sql/associations/one_to_many"
require "rom/sql/associations/many_to_one"

require "hanami/model/associations/has_many"
require "hanami/model/associations/belongs_to"
require "hanami/model/associations/has_many"
require "hanami/model/associations/has_one"
require "hanami/model/associations/many_to_many"

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
        when ROM::SQL::Associations::ManyToMany
          Associations::ManyToMany
        when ROM::SQL::Associations::OneToOne
          Associations::HasOne
        when ROM::SQL::Associations::OneToMany
          Associations::HasMany
        when ROM::SQL::Associations::ManyToOne
          Associations::BelongsTo
        else
          raise "Unsupported association: #{association}"
        end
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
