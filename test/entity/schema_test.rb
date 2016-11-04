require 'test_helper'

describe Hanami::Entity::Schema do
  let(:described_class) { Hanami::Entity::Schema }

  describe 'without definition' do
    let(:subject) { described_class.new }

    describe '#call' do
      it 'processes attributes' do
        result = subject.call('foo' => 'bar')

        result.must_equal(foo: 'bar')
      end
    end

    describe '#attribute?' do
      it 'always returns true' do
        subject.attribute?(:foo).must_equal true
      end
    end
  end

  describe 'with definition' do
    let(:subject) do
      described_class.new do
        attribute :id, Hanami::Model::Types::Schema::Int
      end
    end

    describe '#call' do
      it 'processes attributes' do
        result = subject.call(id: '1')

        result.must_equal(id: 1)
      end

      it 'ignores unknown attributes' do
        result = subject.call(foo: 'bar')

        result.must_equal({})
      end
    end

    describe '#attribute?' do
      it 'returns true for known attributes' do
        subject.attribute?(:id).must_equal true
      end

      it 'returns false for unknown attributes' do
        subject.attribute?(:foo).must_equal false
      end
    end
  end
end
