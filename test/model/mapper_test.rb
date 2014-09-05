require 'test_helper'

describe Lotus::Model::Mapper do
  before do
    @mapper = Lotus::Model::Mapper.new
  end

  describe '#initialize' do
    before do
      class FakeCoercer
      end
    end

    after do
      Object.send(:remove_const, :FakeCoercer)
    end

    it 'uses the given coercer' do
      mapper  = Lotus::Model::Mapper.new(FakeCoercer) do
        collection :articles do
        end
      end

      mapper.collection(:articles).coercer_class.must_equal(FakeCoercer)
    end

    it 'executes the given block' do
      mapper = Lotus::Model::Mapper.new do
        collection :articles do
          entity Article
        end
      end.load!

      mapper.collection(:articles).must_be_kind_of Lotus::Model::Mapping::Collection
    end
  end

  describe '#collections' do
    before do
      @mapper = Lotus::Model::Mapper.new do
        collection :teas do
        end
      end
    end

    it 'returns the mapped collections' do
      name, collection = @mapper.collections.first

      name.must_equal :teas
      collection.must_be_kind_of Lotus::Model::Mapping::Collection
    end
  end

  describe '#collection' do
    describe 'when a block is given' do
      it 'register a collection' do
        @mapper.collection :users do
          entity User
        end

        @mapper.load!

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

          @mapper.load!
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

  describe '#load!' do
    let(:association) {Lotus::Model::Associations::OneToMany.new(collection: :articles, foreign_key: :user_id, name: :articles)}

    before do
      @mapper.collection :users do
        entity User
      end

      @mapper.collection :articles do
        entity Article
      end

      @mapper.collection(:users).associations[:articles] = association
    end

    it 'configures repositories for associations' do
      association.repository.must_be_nil
      @mapper.load!
      association.repository.must_equal ArticleRepository
    end
  end
end
