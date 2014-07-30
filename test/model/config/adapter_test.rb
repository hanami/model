require 'test_helper'

describe Lotus::Model::Config::Adapter do

  describe '#load!' do
    let(:mapper) { Lotus::Model::Mapper.new }
    let(:config) { Lotus::Model::Config::Adapter.new(:memory) }

    before do
      @adapter = config.load!(mapper)
    end

    it 'instantiates adapter object' do
      @adapter.must_be_kind_of Lotus::Model::Adapters::MemoryAdapter
    end
  end

end
