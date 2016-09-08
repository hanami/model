require 'rom-repository'

module Hanami
  class Repository < ROM::Repository::Root
    class << self
      def configuration
        Hanami::Model.configuration
      end

      def container
        Hanami::Model.container
      end

      def relation(name, &block)
        configuration.relation(name, &block)
        relations(name)
        root(name)
      end

      def mapping(&block)
        root = self.root
        configuration.mappers { define(root, &block) }
        configuration.define_mappings(root, &block)
      end
    end

    def initialize
      super(self.class.container)
    end
  end
end
