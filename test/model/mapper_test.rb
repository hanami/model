require 'test_helper'

describe Lotus::Model::Mapper do
  before do
    @mapper = Lotus::Model::Mapper.new
  end

  describe '#initialize' do
    it 'executes the given block' do
      mapper = Lotus::Model::Mapper.new do
        collection :articles do
          entity Article
        end
      end

      mapper.collection(:articles).must_be_kind_of Lotus::Model::Mapping::Collection
    end
  end

  describe '#collection' do
    describe 'when a block is given' do
      it 'register a collection' do
        @mapper.collection :users do
          entity User
        end

        collection = @mapper.collection(:users)
        collection.must_be_kind_of Lotus::Model::Mapping::Collection
        collection.name.must_equal :users
      end
    end

    describe 'when only the name is passed' do
      describe 'and the collection is present' do
        before do
          @mapper.collection :users do
            entity User
          end
        end

        it 'returns the collection' do
          collection = @mapper.collection(:users)

          collection.must_be_kind_of(Lotus::Model::Mapping::Collection)
          collection.name.must_equal :users
        end
      end

      describe 'and the collection is missing' do
        it 'raises an error' do
          -> { @mapper.collection(:unknown) }.must_raise(Lotus::Model::Mapping::UnmappedCollectionError)
        end
      end
    end
  end
end
