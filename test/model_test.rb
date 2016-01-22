require 'test_helper'

describe Hanami::Model do
  before do
    Hanami::Model.unload!
  end

  describe '.configuration' do
    it 'exposes class configuration' do
      Hanami::Model.configuration.must_be_kind_of(Hanami::Model::Configuration)
    end
  end

  describe '.duplicate' do
    before do
      Hanami::Model.configure do
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
        Model = Hanami::Model.duplicate(self)
      end

      module DuplicatedConfigure
        Model = Hanami::Model.duplicate(self) do
          reset!

          if Hanami::Utils.jruby?
            adapter type: :sql, uri: 'jdbc:sqlite:path/database.sqlite3'
          else
            adapter type: :sql, uri: 'sqlite3://path/database.sqlite3'
          end
        end
      end
    end

    after do
      Hanami::Model.configuration.reset!

      Object.send(:remove_const, :Duplicated)
      Object.send(:remove_const, :DuplicatedConfigure)
    end

    # Bug
    # See https://github.com/hanami/model/issues/154
    it 'duplicates the configuration of the framework' do
      actual = Duplicated::Model.configuration
      assert actual == Hanami::Model::Configuration.new
    end

    it 'duplicates a namespace for entity' do
      assert defined?(Duplicated::Entity), 'Duplicated::Entity expected'
    end

    it 'duplicates a namespace for repository' do
      assert defined?(Duplicated::Repository), 'Duplicated::Repository expected'
    end

    if Hanami::Utils.jruby?
      it 'optionally accepts a block to configure the duplicated module' do
        configuration = DuplicatedConfigure::Model.configuration

        configuration.adapter_config.uri.wont_equal 'postgres://localhost/database'
        configuration.adapter_config.uri.must_equal 'jdbc:sqlite:path/database.sqlite3'
      end
    else
      it 'optionally accepts a block to configure the duplicated module' do
        configuration = DuplicatedConfigure::Model.configuration

        configuration.adapter_config.uri.wont_equal 'postgres://localhost/database'
        configuration.adapter_config.uri.must_equal 'sqlite3://path/database.sqlite3'
      end
    end
  end

  describe '.configure' do
    after do
      Hanami::Model.unload!
    end

    it 'returns self' do
      returning = Hanami::Model.configure { }
      returning.must_equal(Hanami::Model)
    end

    describe '.adapter' do
      before do
        Hanami::Model.configure do
          adapter type: :sql, uri: 'postgres://localhost/database'
        end
      end

      it 'allows to register SQL adapter configuration' do
        adapter_config = Hanami::Model.configuration.adapter_config
        adapter_config.type.must_equal :sql
        adapter_config.uri.must_equal 'postgres://localhost/database'
      end
    end

    describe '.mapping' do
      before do
        Hanami::Model.configure do
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
        mapper_config = Hanami::Model.configuration.instance_variable_get(:@mapper_config)
        mapper_config.must_be_instance_of Hanami::Model::Config::Mapper
      end
    end
  end
end
