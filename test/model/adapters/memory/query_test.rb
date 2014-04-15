require 'test_helper'

describe Lotus::Model::Adapters::Memory::Query do
  before do
    @query = Lotus::Model::Adapters::Memory::Query.new([], [])
  end

  describe '#negate!' do
    it 'raises an error' do
      -> { @query.negate! }.must_raise NotImplementedError
    end
  end
end
