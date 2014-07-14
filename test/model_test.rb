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
      Lotus::Model.adapter :sql, 'postgres://localhost/database', default: true
    end

    after do
      Lotus::Model.adapters = {}
    end

    it 'allows to register SQL adapter' do
      adapter = Lotus::Model.adapters[:sql]

      adapter.default.must_equal(true)
      adapter.uri.must_equal('postgres://localhost/database')
    end
  end

  describe '.adapters' do
    before do
      Lotus::Model.adapter :redis, 'redis://localhost/database'
    end

    after do
      Lotus::Model.adapters = {}
    end

    it 'returns registered adapters' do
      Lotus::Model.adapters.count.must_equal 1
      Lotus::Model.adapters[:redis].wont_be_nil
    end
  end
end
