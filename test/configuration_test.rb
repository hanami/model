require 'test_helper'

describe Lotus::Model::Configuration do
  before do
    module CustomApplication
    end

    @configuration = Lotus::Model::Configuration.new
  end

  after do
    Object.send(:remove_const, :CustomApplication)
  end

  describe '#adapters' do
    it 'returns empty hash by default' do
      @configuration.adapters.must_equal({})
    end
  end

  describe '#adapter' do
    it 'registers a new adapter' do
      @configuration.adapter(:sql, 'postgres://localhost/db', :type => :sql, :default => true)
      assert(@configuration.adapters.has_key?(:sql), true)
    end

    it 'registers an adapter as default' do
      @configuration.adapter(:sql, 'postgres://localhost/db', :type => :sql, :default => true)
      @configuration.default_adapter.wont_be_nil
    end
  end

end
