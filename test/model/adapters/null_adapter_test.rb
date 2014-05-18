require 'test_helper'

describe Lotus::Model::Adapters::NullAdapter do
  let(:adapter) { Lotus::Model::Adapters::NullAdapter.new }

  it 'raises error when called' do
    -> { adapter.create }.must_raise NoAdapterError
  end
end