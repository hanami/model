require 'test_helper'
require 'ostruct'

describe Hanami::Entity do
  let(:described_class) do
    Class.new { include Hanami::Entity }
  end

  let(:input) do
    Class.new do
      def to_h
        Hash[a: 1]
      end
    end.new
  end

  describe '#initialize' do
    it 'can be instantiated without attributes' do
      described_class.new
    end

    it 'accepts a hash' do
      entity = described_class.new(foo: 1, 'bar' => 2)

      entity.foo.must_equal 1
      entity.bar.must_equal 2
    end

    it 'accepts object that implements #to_h' do
      entity = described_class.new(input)

      entity.a.must_equal 1
    end

    it 'freezes the intance' do
      entity = described_class.new

      entity.must_be :frozen?
    end
  end

  describe '#id' do
    it 'returns the value' do
      entity = described_class.new(id: 1)

      entity.id.must_equal 1
    end

    it 'returns nil if not present in attributes' do
      entity = described_class.new

      entity.id.must_equal nil
    end
  end

  describe 'accessors' do
    it 'exposes accessors for given keys' do
      entity = described_class.new(name: 'Luca')

      entity.name.must_equal 'Luca'
    end

    it 'raises error for unknown attribute' do
      entity = described_class.new(foo: 1)

      exception = -> { entity.bar }.must_raise(NoMethodError)
      exception.message.must_include "undefined method `bar'"
    end

    it 'encapsulates raw attributes' do
      entity = described_class.new

      exception = -> { entity.attributes }.must_raise(NoMethodError)
      exception.message.must_include "undefined method `attributes'"
    end
  end

  describe 'equality' do
    it 'returns true if same class and same id' do
      entity1 = described_class.new(id: 1)
      entity2 = described_class.new(id: 1)

      assert entity1 == entity2, "Expected #{entity1.inspect} to equal #{entity2.inspect}"
    end

    it 'returns false if same class but different id' do
      entity1 = described_class.new(id: 1)
      entity2 = described_class.new(id: 1000)

      refute entity1 == entity2, "Expected #{entity1.inspect} to NOT equal #{entity2.inspect}"
    end

    it 'returns false if different class but same id' do
      entity1 = described_class.new(id: 1)
      entity2 = OpenStruct.new(id: 1)

      refute entity1 == entity2, "Expected #{entity1.inspect} to NOT equal #{entity2.inspect}"
    end

    it 'returns false if different class and different id' do
      entity1 = described_class.new(id: 1)
      entity2 = OpenStruct.new(id: 1000)

      refute entity1 == entity2, "Expected #{entity1.inspect} to NOT equal #{entity2.inspect}"
    end

    it 'returns true when both the ids are nil' do
      entity1 = described_class.new
      entity2 = described_class.new

      assert entity1 == entity2, "Expected #{entity1.inspect} to equal #{entity2.inspect}"
    end
  end

  describe '#hash' do
    it 'returns predictable object hashing' do
      entity1 = described_class.new(id: 1)
      entity2 = described_class.new(id: 1)

      assert entity1.hash == entity2.hash, "Expected #{entity1.hash} to equal #{entity2.hash}"
    end

    it 'returns different object hash for same class but different id' do
      entity1 = described_class.new(id: 1)
      entity2 = described_class.new(id: 1000)

      refute entity1.hash == entity2.hash, "Expected #{entity1.hash} to NOT equal #{entity2.hash}"
    end

    it 'returns different object hash for different class but same id' do
      entity1 = described_class.new(id: 1)
      entity2 = Class.new { include Hanami::Entity }.new(id: 1)

      refute entity1.hash == entity2.hash, "Expected #{entity1.hash} to NOT equal #{entity2.hash}"
    end

    it 'returns different object hash for different class and different id' do
      entity1 = described_class.new(id: 1)
      entity2 = Class.new { include Hanami::Entity }.new(id: 2)

      refute entity1.hash == entity2.hash, "Expected #{entity1.hash} to NOT equal #{entity2.hash}"
    end
  end

  describe '#to_h' do
    it 'serializes attributes into hash' do
      entity = described_class.new(foo: 1, 'bar' => { 'baz' => 2 })

      entity.to_h.must_equal Hash[foo: 1, bar: { baz: 2 }]
    end

    it 'must be an instance of ::Hash' do
      entity = described_class.new

      entity.to_h.must_be_instance_of(::Hash)
    end

    it 'prevents information escape' do
      entity = described_class.new(a: [1, 2, 3])

      entity.to_h[:a].reverse!
      entity.a.must_equal([1, 2, 3])
    end

    it 'is aliased as #to_hash' do
      entity = described_class.new(foo: 'bar')

      entity.to_h.must_equal entity.to_hash
    end
  end

  describe '#respond_to?' do
    it 'returns ture for id' do
      entity = described_class.new

      entity.must_respond_to(:id)
    end

    it 'returns true for present keys' do
      entity = described_class.new(foo: 1, 'bar' => 2)

      entity.must_respond_to(:foo)
      entity.must_respond_to(:bar)
    end

    it 'returns false for missing keys' do
      entity = described_class.new

      entity.wont_respond_to(:baz)
    end
  end
end
