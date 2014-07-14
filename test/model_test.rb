require 'test_helper'

describe Lotus::Model do
  describe '.configure' do
    it 'evaluates the configuration block' do
      -> do
        Lotus::Model.configure do
          raise 'the block has been evaluated'
        end
      end.must_raise RuntimeError
    end
  end

  describe '.adapter' do
    before do
      Lotus::Model.class_eval do
        configure do
          adapter :sql, 'postgres://localhost/database', default: true
        end
      end
    end

    after do
      Lotus::Model.configuration.reset!
    end

    it 'allows to register SQL adapter' do
      adapter = Lotus::Model.configuration.adapters[:sql]
      adapter.uri.must_equal('postgres://localhost/database')

      Lotus::Model.configuration.adapters[:default].must_equal adapter
    end
  end

  describe '.adapters' do
    before do
      Lotus::Model.class_eval do
        configure do
          adapter :sql, 'postgres://localhost/database', default: true
          adapter :redis, 'redis://localhost/database'
        end
      end
    end

    after do
      Lotus::Model.configuration.reset!
    end

    it 'returns registered adapters' do
      Lotus::Model.configuration.adapters[:redis].wont_be_nil
      Lotus::Model.configuration.adapters[:sql].wont_be_nil
    end

    it 'returns default adapters' do
      default_adapter = Lotus::Model.configuration.adapters[:default]
      default_adapter.name.must_equal :sql
    end
  end
end
