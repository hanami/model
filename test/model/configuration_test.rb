require 'test_helper'

describe Lotus::Model::Configuration do
  before do
    @configuration = Lotus::Model::Configuration.new
  end

  describe '#adapter' do
    it 'defaults to an empty set' do
      @configuration.adapters.must_be_empty
    end

    it 'allows to register adapter' do
      @configuration.adapter(:sql, 'postgres://localhost/database')

      adapter = @configuration.adapters.fetch(:sql)
      adapter.must_be_kind_of Lotus::Model::Config::Adapter
      adapter.uri.must_equal 'postgres://localhost/database'
    end

    it 'allows to register default adapter' do
      @configuration.adapter(:sql, 'postgres://localhost/database', default: true)

      default_adapter = @configuration.adapters.fetch(:default)
      default_adapter.must_be_kind_of Lotus::Model::Config::Adapter
      default_adapter.uri.must_equal 'postgres://localhost/database'
    end

    it 'eliminates duplications' do
      @configuration.adapter(:sql, 'postgres://localhost/database')
      @configuration.adapter(:sql, 'postgres://localhost/database')

      @configuration.adapters.size.must_equal(1)
    end
  end

end
