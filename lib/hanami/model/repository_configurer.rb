# frozen_string_literal: true

module Hanami
  module Model
    # Repository configurer
    #
    # @since x.x.x
    # @api private
    class RepositoryConfigurer
      # Configure a repository
      #
      # @param [Hanami::Repository] the repository
      # @param [Hanami::Model::Configuration] a configuration
      #
      # @since x.x.x
      # @api private
      def self.call(repository, configuration)
        # define_relation(repository, configuration)
        define_mapping(repository, configuration)
      end

      # @since x.x.x
      # @api private
      #
      # rubocop:disable Metrics/MethodLength
      def self.define_relation(repository, configuration)
        a = repository.associations
        s = repository.schema

        configuration.relation(repository.relation) do
          if s.nil?
            schema(infer: true) do
              associations(&a) unless a.nil?
            end
          else
            schema(&s)
          end
        end

        repository.root(repository.relation)
      end
      # rubocop:enable Metrics/MethodLength

      # @since x.x.x
      # @api private
      #
      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/MethodLength
      def self.define_mapping(repository, configuration)
        repository.entity = Utils::Class.load!(repository.entity_name)
        e = repository.entity
        m = repository.mapping

        blk = lambda do |_|
          model       e
          register_as :entity
          # instance_exec(&m) unless m.nil?
        end

        root = repository.root
        configuration.mappers { define(root, &blk) }
        configuration.define_mappings(root, &blk)
        configuration.register_entity(repository.relation, repository.entity_name.underscore, e)
      end
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize
  end
end
