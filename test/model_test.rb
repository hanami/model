require 'test_helper'

describe Lotus::Model do
  describe '.configuration' do
    it 'exposes class configuration' do
      Lotus::Model.configuration.must_be_kind_of(Lotus::Model::Configuration)
    end
  end

  describe '.configure' do
    describe '.adapter' do
      before do
        Lotus::Model::configure do
          adapter :sql, 'postgres://localhost/database', default: true
        end
      end

      after do
        Lotus::Model.configuration.reset!
      end

      it 'allows to register SQL adapter' do
        adapter = Lotus::Model.configuration.adapters.fetch(:sql)
        adapter.uri.must_equal('postgres://localhost/database')

        Lotus::Model.configuration.adapters.fetch(:default).must_equal adapter
      end
    end

    describe '.adapters' do
      before do
        Lotus::Model.configure do
          adapter :sql, 'postgres://localhost/database', default: true
          adapter :redis, 'redis://localhost/database'
        end
      end

      after do
        Lotus::Model.configuration.reset!
      end

      it 'returns registered adapters' do
        Lotus::Model.configuration.adapters.fetch(:redis).wont_be_nil
        Lotus::Model.configuration.adapters.fetch(:sql).wont_be_nil
      end

      it 'returns default adapters' do
        default_adapter = Lotus::Model.configuration.adapters.fetch(:default)
        default_adapter.name.must_equal :sql
      end
    end
  end
end
