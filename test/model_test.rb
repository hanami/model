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
    it 'allows to register SQL adapter' do
      Lotus::Model.adapter :sql, 'postgres://localhost/database', default: true

      adapter = Lotus::Model.adapters[:sql]

      adapter.default.must_equal(true)
      adapter.uri.must_equal('postgres://localhost/database')
    end
  end
end
