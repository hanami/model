require 'test_helper'
require 'lotus/entity'
require 'lotus/repository'
require 'lotus/model/mapper'
require 'lotus/model/adapters/memory_adapter'

describe 'load mapper' do
  before do
    class MyTestEntity
      include Lotus::Entity
      self.attributes = :title
    end
    class MyTestRepository
      include Lotus::Repository
    end
    @mapping = Lotus::Model::Mapper.new do
      collection :test_entity do
        entity     MyTestEntity
        repository MyTestRepository

        attribute :id, Integer
        attribute :title, String
      end
    end

    @adapter = Lotus::Model::Adapters::MemoryAdapter.new(@mapping)
    MyTestRepository.adapter = @adapter
  end
  after do
    Object.send(:remove_const, :MyTestEntity)
    Object.send(:remove_const, :MyTestRepository)
  end

  it 'should preserve assigned adapter' do
    MyTestRepository.send(:adapter).must_equal(@adapter)
    @mapping.load!
    MyTestRepository.send(:adapter).must_equal(@adapter)
  end
end
