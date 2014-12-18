require 'test_helper'

describe Lotus::Model do
  before do
    Lotus::Model.unload!
  end

  describe '.configuration' do
    it 'exposes class configuration' do
      Lotus::Model.configuration.must_be_kind_of(Lotus::Model::Configuration)
    end
  end

  describe '.duplicate' do
    before do
      Lotus::Model.configure do
        adapter type: :sql, uri: 'postgres://localhost/database'

        mapping do
          collection :users do
            entity User

            attribute :id, Integer
            attribute :name, String
          end
        end
      end

      module Duplicated
        Model = Lotus::Model.duplicate(self)
      end

      module DuplicatedConfigure
        Model = Lotus::Model.duplicate(self) do
          reset!
          adapter type: :sql, uri: 'sqlite3://path/database.sqlite3'
        end
      end
    end

    after do
      Lotus::Model.configuration.reset!

      Object.send(:remove_const, :Duplicated)
      Object.send(:remove_const, :DuplicatedConfigure)
    end

    it 'duplicates the configuration of the framework' do
      actual   = Duplicated::Model.configuration
      expected = Lotus::Model.configuration

      actual.adapter_config.must_equal expected.adapter_config
      actual.mapper.must_equal expected.mapper
    end

    it 'duplicates a namespace for entity' do
      assert defined?(Duplicated::Entity), 'Duplicated::Entity expected'
    end

    it 'duplicates a namespace for repository' do
      assert defined?(Duplicated::Repository), 'Duplicated::Repository expected'
    end

    it 'optionally accepts a block to configure the duplicated module' do
      configuration = DuplicatedConfigure::Model.configuration

      configuration.adapter_config.uri.wont_equal 'postgres://localhost/database'
      configuration.adapter_config.uri.must_equal 'sqlite3://path/database.sqlite3'
    end
  end

  describe '.configure' do
    after do
      Lotus::Model.unload!
    end

    it 'returns self' do
      returning = Lotus::Model.configure { }
      returning.must_equal(Lotus::Model)
    end

    describe '.adapter' do
      before do
        Lotus::Model.configure do
          adapter type: :sql, uri: 'postgres://localhost/database'
        end
      end

      it 'allows to register SQL adapter configuration' do
        adapter_config = Lotus::Model.configuration.adapter_config
        adapter_config.type.must_equal :sql
        adapter_config.uri.must_equal 'postgres://localhost/database'
      end
    end

    describe '.mapping' do
      before do
        Lotus::Model.configure do
          mapping do
            collection :users do
              entity User

              attribute :id, Integer
              attribute :name, String
            end
          end
        end
      end

      it 'configures the global persistence mapper' do
        mapping = Lotus::Model.configuration.instance_variable_get(:@mapping)
        assert mapping.is_a?(Proc)
      end
    end
  end
end
