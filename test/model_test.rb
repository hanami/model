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

      module DuplicatedCustom
        Model = Lotus::Model.duplicate(self, 'SuperModels')
      end

      module DuplicatedWithoutNamespace
        Model = Lotus::Model.duplicate(self, nil)
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
      Object.send(:remove_const, :DuplicatedCustom)
      Object.send(:remove_const, :DuplicatedWithoutNamespace)
      Object.send(:remove_const, :DuplicatedConfigure)
    end

    it 'duplicates the configuration of the framework' do
      actual   = Duplicated::Model.configuration
      expected = Lotus::Model.configuration

      actual.adapter_config.must_equal expected.adapter_config
      actual.mapper.must_equal expected.mapper
    end

    it 'duplicates a namespace for models' do
      assert defined?(Duplicated::Models), 'Duplicated::Models expected'
    end

    it 'duplicates a namespace for entity' do
      assert defined?(Duplicated::Entity), 'Duplicated::Entity expected'
    end

    it 'duplicates a namespace for repository' do
      assert defined?(Duplicated::Repository), 'Duplicated::Repository expected'
    end

    it 'generates a custom namespace for models' do
      assert defined?(DuplicatedCustom::SuperModels), 'DuplicatedCustom::SuperModel expected'
    end

    it 'does not create a custom namespace for models' do
      assert !defined?(DuplicatedWithoutNamespace::Models), "DuplicatedWithoutNamespace::Models wasn't expected"
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
        collection = Lotus::Model.configuration.mapper.collection(:users)
        collection.must_be_kind_of Lotus::Model::Mapping::Collection
        collection.name.must_equal :users
      end
    end
  end
end
