# frozen_string_literal: true

RSpec.describe Hanami::Entity, skip: true do
  describe "automatic schema" do
    let(:described_class) { Project::Entities::Author }

    let(:input) do
      Class.new do
        def to_hash
          Hash[id: 1]
        end
      end.new
    end

    describe "#initialize" do
      it "can be instantiated without attributes" do
        entity = described_class.new

        expect(entity).to be_a_kind_of(described_class)
      end

      it "accepts a hash" do
        entity = described_class.new(id: 1, name: "Luca", books: books = [Book.new], created_at: now = Time.now.utc)

        expect(entity.id).to eq(1)
        expect(entity.name).to eq("Luca")
        expect(entity.books).to eq(books)
        expect(entity.created_at).to be_within(2).of(now)
      end

      it "accepts object that implements #to_hash" do
        entity = described_class.new(input)

        expect(entity.id).to eq(1)
      end

      it "freezes the instance" do
        entity = described_class.new

        expect(entity).to be_frozen
      end

      it "coerces values" do
        now = Time.now
        entity = described_class.new(created_at: now.to_s)

        expect(entity.created_at).to be_within(2).of(now)
      end

      it "coerces values for array of objects" do
        entity = described_class.new(books: books = [{ title: "TDD" }, { title: "Refactoring" }])

        books.each_with_index do |book, i|
          b = entity.books[i]

          expect(b).to be_a_kind_of(Book)
          expect(b.title).to eq(book.fetch(:title))
        end
      end

      it "raises error if initialized with wrong array object" do
        expect { described_class.new(books: [Object.new]) }.to raise_error(NoMethodError, /to_hash/)
      end
    end

    describe "#id" do
      it "returns the value" do
        entity = described_class.new(id: 1, name: "Bob")
        expect(entity.id).to eq(1)
      end

      it "returns nil if not present in attributes" do
        entity = described_class.new

        expect(entity.id).to be_nil
      end
    end

    describe "accessors" do
      it "exposes accessors from schema" do
        entity = described_class.new(name: "Luca")

        expect(entity.name).to eq("Luca")
      end

      it "raises error for unknown methods" do
        entity = described_class.new

        expect { entity.foo }
          .to raise_error(NoMethodError, /undefined method `foo'/)
      end

      it "raises error when #attributes is invoked" do
        entity = described_class.new

        expect { entity.attributes }
          .to raise_error(NoMethodError, /private method `attributes' called for #<Author/)
      end
    end

    describe "#to_h" do
      it "serializes attributes into hash" do
        entity = described_class.new(id: 1, name: "Luca")

        expect(entity.to_h).to eq(Hash[id: 1, name: "Luca"])
      end

      it "must be an instance of ::Hash" do
        entity = described_class.new

        expect(entity.to_h).to be_an_instance_of(::Hash)
      end

      it "ignores unknown attributes" do
        entity = described_class.new(foo: "bar")

        expect(entity.to_h).to eq(Hash[])
      end

      it "prevents information escape" do
        entity = described_class.new(books: books = [Project::Entities::Book.new(id: 1), Project::Entities::Book.new(id: 2)])

        entity.to_h[:books].reverse!
        expect(entity.books).to eq(books)
      end

      it "is aliased as #to_hash" do
        entity = described_class.new(name: "Luca")

        expect(entity.to_hash).to eq(entity.to_h)
      end
    end

    describe "#respond_to?" do
      it "returns ture for id" do
        entity = described_class.new

        expect(entity).to respond_to(:id)
      end

      it "returns true for methods with the same name of attributes defined by schema" do
        entity = described_class.new

        expect(entity).to respond_to(:name)
      end

      it "returns false for methods not in the set of attributes defined by schema" do
        entity = described_class.new(foo: "bar")

        expect(entity).to_not respond_to(:foo)
      end
    end
  end
end
