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
          adapter :sql, 'postgres://localhost/database', default: true
        end
      end

      after do
        Lotus::Model.configuration.reset!
      end

      it 'allows to register SQL adapter configuration' do
        adapter = Lotus::Model.configuration.adapter_configs.fetch(:sql)
        adapter.uri.must_equal('postgres://localhost/database')

        Lotus::Model.configuration.adapter_configs.default.must_equal adapter
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
