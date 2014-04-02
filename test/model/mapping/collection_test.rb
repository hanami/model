require 'test_helper'

describe Lotus::Model::Mapping::Collection do
  before do
    @collection = Lotus::Model::Mapping::Collection.new(:users)
  end

  describe '#initialize' do
    it 'assigns the name' do
      @collection.name.must_equal :users
    end

    it 'executes the given block' do
      collection = Lotus::Model::Mapping::Collection.new :users do
        entity User
      end

      collection.entity.must_equal User
    end
  end

  describe '#entity' do
    describe 'when a value is given' do
      before do
        @collection.entity(User)
      end

      it 'sets the value' do
        @collection.entity.must_equal User
      end
    end

    describe 'when a value is not given' do
      it 'retuns the value' do
        @collection.entity.must_be_nil
      end
    end
  end

  describe '#adapter' do
    describe 'when a value is given' do
      before do
        @collection.adapter(:memory)
      end

      it 'sets the value' do
        @collection.adapter.must_equal :memory
      end
    end

    describe 'when a value is not given' do
      it 'retuns the value' do
        @collection.adapter.must_be_nil
      end
    end
  end

  describe '#attribute' do
    before do
      @collection.attribute :id, Integer
    end

    it 'defines an attribute' do
      @collection.attributes[:id].must_equal Integer
    end
  end
end
