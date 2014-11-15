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

  describe '.configure' do
    describe '.adapter' do
      before do
        Lotus::Model.configure do
          adapter type: :sql, uri: 'postgres://localhost/database'
        end
      end

      after do
        Lotus::Model.configuration.reset!
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

      after do
        Lotus::Model.configuration.reset!
      end

      it 'configures the global persistence mapper' do
        collection = Lotus::Model.configuration.mapper.collection(:users)
        collection.must_be_kind_of Lotus::Model::Mapping::Collection
        collection.name.must_equal :users
      end
    end
  end
end
