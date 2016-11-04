require 'test_helper'

describe Hanami::Model::Sql::Entity::Schema do
  describe 'automatic' do
    let(:subject) { Author.schema }

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
        now    = Time.now
        result = subject.call(id: 1, created_at: now.to_s)

        result.fetch(:id).must_equal(1)
        result.fetch(:created_at).must_be_close_to(now, 1)
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
