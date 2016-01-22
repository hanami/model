require 'test_helper'

describe Hanami::Model::Adapters::Abstract do
  let(:adapter)    { Hanami::Model::Adapters::Abstract.new(mapper) }
  let(:mapper)     { Object.new }
  let(:entity)     { Object.new }
  let(:query)      { Object.new }
  let(:collection) { :collection }

  describe '#persist' do
    it 'raises error' do
      -> { adapter.persist(collection, entity) }.must_raise NotImplementedError
    end
  end

  describe '#create' do
    it 'raises error' do
      -> { adapter.create(collection, entity) }.must_raise NotImplementedError
    end
  end

  describe '#update' do
    it 'raises error' do
      -> { adapter.update(collection, entity) }.must_raise NotImplementedError
    end
  end

  describe '#delete' do
    it 'raises error' do
      -> { adapter.delete(collection, entity) }.must_raise NotImplementedError
    end
  end

  describe '#all' do
    it 'raises error' do
      -> { adapter.all(collection) }.must_raise NotImplementedError
    end
  end

  describe '#find' do
    it 'raises error' do
      -> { adapter.find(collection, 1) }.must_raise NotImplementedError
    end
  end

  describe '#first' do
    it 'raises error' do
      -> { adapter.first(collection) }.must_raise NotImplementedError
    end
  end

  describe '#last' do
    it 'raises error' do
      -> { adapter.last(collection) }.must_raise NotImplementedError
    end
  end

  describe '#clear' do
    it 'raises error' do
      -> { adapter.clear(collection) }.must_raise NotImplementedError
    end
  end

  describe '#command' do
    it 'raises error' do
      -> { adapter.command(query) }.must_raise NotImplementedError
    end
  end

  describe '#query' do
    it 'raises error' do
      -> { adapter.query(collection) }.must_raise NotImplementedError
    end
  end

  describe '#transaction' do
    it 'raises error' do
      -> { adapter.transaction({}) }.must_raise NotImplementedError
    end
  end

  describe '#connection_string' do
    it 'raises error' do
      -> { adapter.connection_string }.must_raise Hanami::Model::Adapters::NotSupportedError
    end
  end
end
