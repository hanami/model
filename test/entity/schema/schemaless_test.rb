require 'test_helper'

describe Hanami::Entity::Schema::Schemaless do
  let(:subject) { Hanami::Entity::Schema::Schemaless.new }

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

    it 'returns duped hash' do
      input  = { foo: 'bar' }
      result = subject.call(input)

      result.must_equal(input)
      result.object_id.wont_equal(input.object_id)
    end
  end

  describe '#attribute?' do
    it 'always returns true' do
      subject.attribute?(:foo).must_equal true
    end
  end
end
