require 'test_helper'

describe Hanami::Model::Sql::Entity::Schema do
  describe 'mapping' do
    let(:subject) { Operator.schema }

    describe '#initialize' do
      it 'returns frozen instance' do
        subject.must_be :frozen?
      end
    end

    describe '#call' do
      it 'returns empty hash when nil is given' do
        result = subject.call(nil)

        result.must_equal({})
      end

      it 'processes attributes' do
        result = subject.call(id: 1, name: :foo)

        result.must_equal(id: 1, name: 'foo')
      end

      it 'ignores unknown attributes' do
        result = subject.call(foo: 'bar')

        result.must_equal({})
      end

      it 'raises error if the process fails' do
        exception = lambda do
          subject.call(id: :foo)
        end.must_raise(TypeError)

        exception.message.must_equal ':foo (Symbol) has invalid type for :id'
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
