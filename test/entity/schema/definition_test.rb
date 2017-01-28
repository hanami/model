require 'test_helper'

describe Hanami::Entity::Schema::Definition do
  let(:described_class) { Hanami::Entity::Schema::Definition }
  let(:subject) do
    described_class.new do
      attribute :id, Hanami::Model::Types::Coercible::Int
    end
  end

  describe '#initialize' do
    it 'returns frozen instance' do
      subject = described_class.new {}

      subject.must_be :frozen?
    end

    it "raises error if block isn't given" do
      lambda do
        described_class.new
      end.must_raise(LocalJumpError)
    end
  end

  describe '#call' do
    it 'returns empty hash when nil is given' do
      result = subject.call(nil)

      result.must_equal({})
    end

    it 'processes attributes' do
      result = subject.call(id: 1)

      result.must_equal(id: 1)
    end

    it 'ignores unknown attributes' do
      result = subject.call(foo: 'bar')

      result.must_equal({})
    end

    it 'raises error if the process fails' do
      exception = lambda do
        subject.call(id: :foo)
      end.must_raise(TypeError)

      message = Platform.match do
        engine(:jruby) { "no implicit conversion of Symbol into Integer" }
        default        { "can't convert Symbol into Integer" }
      end

      exception.message.must_equal message
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
