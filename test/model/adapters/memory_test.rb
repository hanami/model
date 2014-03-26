require 'test_helper'

describe Lotus::Model::Adapters::Memory do
  before do
    TestEntity = Struct.new(:id, :name)
    @adapter   = Lotus::Model::Adapters::Memory.new
  end

  after do
    Object.send(:remove_const, :TestEntity)
  end

  describe '#persist' do
    describe 'when the given entity is not persisted' do
      let(:entity) { TestEntity.new }

      it 'stores the record and assigns an id' do
        @adapter.persist(entity)

        entity.id.wont_be_nil
        @adapter.find(entity.id).must_equal entity
      end
    end

    describe 'when the given entity is persisted' do
      before do
        @adapter.create(entity)
      end

      let(:entity) { TestEntity.new }

      it 'updates the record and leaves untouched the id' do
        id = entity.id
        id.wont_be_nil

        entity.name = 'L'
        @adapter.persist(entity)

        entity.id.must_equal(id)
        @adapter.find(entity.id).must_equal entity
      end
    end
  end

  describe '#create' do
    let(:entity) { TestEntity.new }

    it 'stores the record and assigns an id' do
      @adapter.create(entity)

      entity.id.wont_be_nil
      @adapter.find(entity.id).must_equal entity
    end
  end

  describe '#update' do
    before do
      @adapter.create(entity)
    end

    let(:entity) { TestEntity.new(nil, 'L') }

    it 'stores the changes and leave the id untouched' do
      id = entity.id

      entity.name = 'MG'
      @adapter.update(entity)

      entity.id.must_equal id
      @adapter.find(entity.id).must_equal entity
    end
  end

  describe '#delete' do
    before do
      @adapter.create(entity)
    end

    let(:entity) { TestEntity.new }

    it 'removes the given identity' do
      @adapter.delete(entity)
      @adapter.find(entity.id).must_be_nil
    end
  end

  describe '#all' do
    describe 'when no records are persisted' do
      before do
        @adapter.clear
      end

      it 'returns an empty collection' do
        @adapter.all.must_be_empty
      end
    end

    describe 'when some records are persisted' do
      before do
        @adapter.create(entity)
      end

      let(:entity) { TestEntity.new }

      it 'returns all of them' do
        @adapter.all.must_equal [entity]
      end
    end
  end

  describe '#find' do
    before do
      @adapter.create(entity)
      @adapter.send(:records).store(nil, nil_entity)
    end

    let(:entity)      { TestEntity.new }
    let(:nil_entity)  { TestEntity.new(0) }

    it 'returns the record by id' do
      @adapter.find(entity.id).must_equal entity
    end

    it 'returns nil when the record cannot be found' do
      @adapter.find(1_000_000).must_be_nil
    end

    it 'returns nil when the given id is nil' do
      @adapter.find(nil).must_be_nil
    end
  end

  describe '#first' do
    describe 'when no records are peristed' do
      before do
        @adapter.clear
      end

      it 'returns nil' do
        @adapter.first.must_be_nil
      end
    end

    describe 'when some records are persisted' do
      before do
        @adapter.create(entity1)
        @adapter.create(entity2)
      end

      let(:entity1) { TestEntity.new }
      let(:entity2) { TestEntity.new }

      it 'returns the first record' do
        @adapter.first.must_equal entity1
      end
    end
  end

  describe '#last' do
    describe 'when no records are peristed' do
      before do
        @adapter.clear
      end

      it 'returns nil' do
        @adapter.last.must_be_nil
      end
    end

    describe 'when some records are persisted' do
      before do
        @adapter.create(entity1)
        @adapter.create(entity2)
      end

      let(:entity1) { TestEntity.new }
      let(:entity2) { TestEntity.new }

      it 'returns the last record' do
        @adapter.last.must_equal entity2
      end
    end
  end

  describe '#last' do
    before do
      @adapter.create(entity)
    end

    let(:entity) { TestEntity.new }

    it 'removes all the records' do
      @adapter.clear
      @adapter.all.must_be_empty
    end

    it 'resets the id counter' do
      @adapter.clear

      @adapter.create(entity)
      entity.id.must_equal 1
    end
  end
end
