require 'test_helper'

describe Lotus::Model::Adapters::Implementation do
  before do
    TestAdapter = Class.new(Lotus::Model::Adapters::Abstract) do
      include Lotus::Model::Adapters::Implementation
    end

    @adapter = TestAdapter.new
  end

  after do
    Object.send(:remove_const, :TestAdapter)
  end

  it 'must implement #_collection' do
    -> {
      @adapter.all(:collection)
    }.must_raise NotImplementedError
  end
end
