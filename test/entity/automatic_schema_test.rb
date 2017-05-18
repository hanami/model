require 'test_helper'

describe Hanami::Entity do
  describe 'automatic schema' do
    let(:described_class) { Author }

    let(:input) do
      Class.new do
        def to_hash
          Hash[id: 1]
        end
      end.new
    end

    describe '#initialize' do
      it 'can be instantiated without attributes' do
        entity = described_class.new

        entity.must_be_kind_of(described_class)
      end

      it 'accepts a hash' do
        entity = described_class.new(id: 1, name: 'Luca', books: books = [Book.new], created_at: now = Time.now.utc)

        entity.id.must_equal    1
        entity.name.must_equal  'Luca'
        entity.books.must_equal books
        entity.created_at.must_be_close_to(now, 2)
      end

      it 'accepts object that implements #to_hash' do
        entity = described_class.new(input)

        entity.id.must_equal 1
      end

      it 'freezes the intance' do
        entity = described_class.new

        entity.must_be :frozen?
      end

      it 'coerces values' do
        now    = Time.now
        entity = described_class.new(created_at: now.to_s)

        entity.created_at.must_be_close_to(now, 2)
      end

      it 'coerces values for array of objects' do
        entity = described_class.new(books: books = [{ title: 'TDD' }, { title: 'Refactoring' }])

        books.each_with_index do |book, i|
          b = entity.books[i]

          b.must_be_kind_of(Book)
          b.title.must_equal book.fetch(:title)
        end
      end

      it 'raises error if initialized with wrong array object' do
        object    = Object.new
        exception = lambda do
          described_class.new(books: [object])
        end.must_raise(TypeError)

        exception.message.must_include('[#<Object:0x')
        exception.message.must_include('>] (Array) has invalid type for :books')
      end
    end

    describe '#id' do
      it 'returns the value' do
        entity = described_class.new(id: 1)

        entity.id.must_equal 1
      end

      it 'returns nil if not present in attributes' do
        entity = described_class.new

        entity.id.must_be_nil
      end
    end

    describe 'accessors' do
      it 'exposes accessors from schema' do
        entity = described_class.new(name: 'Luca')

        entity.name.must_equal 'Luca'
      end

      it 'raises error for unknown methods' do
        entity = described_class.new

        exception = lambda do
          entity.foo
        end.must_raise(NoMethodError)

        exception.message.must_include "undefined method `foo'"
      end

      it 'raises error when #attributes is invoked' do
        entity = described_class.new

        exception = lambda do
          entity.attributes
        end.must_raise(NoMethodError)

        exception.message.must_include "private method `attributes' called for #<Author"
      end
    end

    describe '#to_h' do
      it 'serializes attributes into hash' do
        entity = described_class.new(id: 1, name: 'Luca')

        entity.to_h.must_equal Hash[id: 1, name: 'Luca']
      end

      it 'must be an instance of ::Hash' do
        entity = described_class.new

        entity.to_h.must_be_instance_of(::Hash)
      end

      it 'ignores unknown attributes' do
        entity = described_class.new(foo: 'bar')

        entity.to_h.must_equal Hash[]
      end

      it 'prevents information escape' do
        entity = described_class.new(books: books = [Book.new(id: 1), Book.new(id: 2)])

        entity.to_h[:books].reverse!
        entity.books.must_equal(books)
      end

      it 'is aliased as #to_hash' do
        entity = described_class.new(name: 'Luca')

        entity.to_hash.must_equal entity.to_h
      end
    end

    describe '#respond_to?' do
      it 'returns ture for id' do
        entity = described_class.new

        entity.must_respond_to(:id)
      end

      it 'returns true for methods with the same name of attributes defined by schema' do
        entity = described_class.new

        entity.must_respond_to(:name)
      end

      it 'returns false for methods not in the set of attributes defined by schema' do
        entity = described_class.new(foo: 'bar')

        entity.wont_respond_to(:foo)
      end
    end
  end
end
