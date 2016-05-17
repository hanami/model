require 'test_helper'

describe Hanami::Model::Adapters::Implementation do
  before do
    TestAdapter = Class.new(Hanami::Model::Adapters::Abstract) do
      include Hanami::Model::Adapters::Implementation
    end

    mapper   = Object.new
    @adapter = TestAdapter.new(mapper, "test://uri")
  end

  after do
    Object.send(:remove_const, :TestAdapter)
  end

  it 'must implement #_collection' do
    -> {
      @adapter.send(:_collection, :x)
    }.must_raise NotImplementedError
  end
end
