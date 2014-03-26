require 'test_helper'

describe Lotus::Model::Adapters::Abstract do
  let(:adapter)    { Lotus::Model::Adapters::Abstract.new }
  let(:entity)     { Object.new }
  let(:collection) { :collection }

  describe '#persist' do
    it 'raises error' do
      ->{ adapter.persist(collection, entity) }.must_raise NotImplementedError
    end
  end

  describe '#create' do
    it 'raises error' do
      ->{ adapter.create(collection, entity) }.must_raise NotImplementedError
    end
  end

  describe '#update' do
    it 'raises error' do
      ->{ adapter.update(collection, entity) }.must_raise NotImplementedError
    end
  end

  describe '#delete' do
    it 'raises error' do
      ->{ adapter.delete(collection, entity) }.must_raise NotImplementedError
    end
  end

  describe '#all' do
    it 'raises error' do
      ->{ adapter.all(collection) }.must_raise NotImplementedError
    end
  end

  describe '#find' do
    it 'raises error' do
      ->{ adapter.find(collection, 1) }.must_raise NotImplementedError
    end
  end

  describe '#first' do
    it 'raises error' do
      ->{ adapter.first(collection) }.must_raise NotImplementedError
    end
  end

  describe '#last' do
    it 'raises error' do
      ->{ adapter.last(collection) }.must_raise NotImplementedError
    end
  end

  describe '#clear' do
    it 'raises error' do
      ->{ adapter.clear(collection) }.must_raise NotImplementedError
    end
  end
end
