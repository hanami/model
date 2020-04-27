# frozen_string_literal: true

RSpec.describe Hanami::Entity do
  describe "schemaless" do
    let(:described_class) do
      Class.new(Hanami::OldEntity[:struct])
    end

    let(:input) do
      Class.new do
        def to_hash
          Hash[a: 1]
        end
      end.new
    end

    describe "#initialize" do
      it "can be instantiated without attributes" do
        entity = described_class.new

        expect(entity).to be_a_kind_of(described_class)
      end

      it "accepts a hash" do
        entity = described_class.new(foo: 1, "bar" => 2)

        expect(entity.foo).to eq(1)
        expect(entity.bar).to eq(2)
      end

      it "accepts object that implements #to_hash" do
        entity = described_class.new(input)

        expect(entity.a).to eq(1)
      end

      it "freezes the instance" do
        entity = described_class.new

        expect(entity).to be_frozen
      end
    end

    describe "#id" do
      it "returns the value" do
        entity = described_class.new(id: 1)

        expect(entity.id).to eq(1)
      end

      it "returns nil if not present in attributes" do
        entity = described_class.new

        expect(entity.id).to be_nil
      end
    end

    describe "accessors" do
      it "exposes accessors for given keys" do
        entity = described_class.new(name: "Luca")

        expect(entity.name).to eq("Luca")
      end

      it "raises error for unknown methods" do
        entity = described_class.new

        # TODO: Maybe wrap on a Hanami::Model::Error
        expect { entity.foo }.to raise_error(ROM::Struct::MissingAttribute)
      end

      it "returns empty hash for #attributes" do
        entity = described_class.new

        expect(entity.attributes).to eq({})
      end
    end

    describe "#to_h" do
      it "serializes attributes into hash" do
        entity = described_class.new(foo: 1, "bar" => { "baz" => 2 })

        expect(entity.to_h).to eq(::Hash[foo: 1, bar: { baz: 2 }])
      end

      it "must be an instance of ::Hash" do
        entity = described_class.new

        expect(entity.to_h).to be_an_instance_of(::Hash)
      end

      it "prevents information escape" do
        entity = described_class.new(a: [1, 2, 3])

        entity.to_h[:a].reverse!
        expect(entity.a).to eq([1, 2, 3])
      end

      it "is aliased as #to_hash" do
        entity = described_class.new(foo: "bar")

        expect(entity.to_h).to eq(entity.to_hash)
      end
    end

    describe "#respond_to?" do
      it "returns ture for id" do
        entity = described_class.new

        expect(entity).to respond_to(:id)
      end

      it "returns true for present keys" do
        entity = described_class.new(foo: 1, "bar" => 2)

        expect(entity).to respond_to(:foo)
        expect(entity).to respond_to(:bar)
      end

      it "returns false for missing keys" do
        entity = described_class.new

        expect(entity).to_not respond_to(:baz)
      end
    end
  end
end
