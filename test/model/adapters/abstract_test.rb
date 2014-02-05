require 'test_helper'

describe Lotus::Model::Adapters::Abstract do
  let(:adapter) { Lotus::Model::Adapters::Abstract.new }
  let(:entity)  { Object.new }

  describe '#persist' do
    it 'raises error' do
      ->{ adapter.persist(entity) }.must_raise NotImplementedError
    end
  end

  describe '#create' do
    it 'raises error' do
      ->{ adapter.create(entity) }.must_raise NotImplementedError
    end
  end

  describe '#update' do
    it 'raises error' do
      ->{ adapter.update(entity) }.must_raise NotImplementedError
    end
  end

  describe '#delete' do
    it 'raises error' do
      ->{ adapter.delete(entity) }.must_raise NotImplementedError
    end
  end

  describe '#all' do
    it 'raises error' do
      ->{ adapter.all }.must_raise NotImplementedError
    end
  end

  describe '#find' do
    it 'raises error' do
      ->{ adapter.find(1) }.must_raise NotImplementedError
    end
  end

  describe '#first' do
    it 'raises error' do
      ->{ adapter.first }.must_raise NotImplementedError
    end
  end

  describe '#last' do
    it 'raises error' do
      ->{ adapter.last }.must_raise NotImplementedError
    end
  end

  describe '#clear' do
    it 'raises error' do
      ->{ adapter.clear }.must_raise NotImplementedError
    end
  end
end
