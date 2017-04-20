require 'test_helper'

describe Hanami::Entity do
  describe 'schemaless' do
    let(:described_class) do
      Class.new(Hanami::Entity)
    end

    let(:input) do
      Class.new do
        def to_hash
          Hash[a: 1]
        end
      end.new
    end

    describe '#initialize' do
      it 'can be instantiated without attributes' do
        entity = described_class.new

        entity.must_be_kind_of(described_class)
      end

      it 'accepts a hash' do
        entity = described_class.new(foo: 1, 'bar' => 2)

        entity.foo.must_equal 1
        entity.bar.must_equal 2
      end

      it 'accepts object that implements #to_hash' do
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

      it 'returns nil for unknown methods' do
        entity = described_class.new

        entity.foo.must_equal nil
      end

      it 'returns nil for #attributes' do
        entity = described_class.new

        entity.attributes.must_equal nil
      end
    end

    describe '#to_h' do
      it 'serializes attributes into hash' do
        entity = described_class.new(foo: 1, 'bar' => { 'baz' => 2 })

        entity.to_h.must_equal Hash[foo: 1, bar: { 'baz' => 2 }]
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

        entity.must_respond_to(:baz)
      end
    end
  end
end
