RSpec.describe Hanami::Entity do
  describe 'manual schema (strict)' do
    let(:described_class) { Person }

    let(:input) do
      Class.new do
        def to_hash
          Hash[id: 2, name: "MG"]
        end
      end.new
    end

    describe '#initialize' do
      it "can't be instantiated without attributes" do
        expect { described_class.new }.to raise_error(ArgumentError, ":id is missing in Hash input")
      end

      it "can't be instantiated with empty hash" do
        expect { described_class.new({}) }.to raise_error(ArgumentError, ":id is missing in Hash input")
      end

      it "can't be instantiated with partial data" do
        expect { described_class.new(id: 1) }.to raise_error(ArgumentError, ":name is missing in Hash input")
      end

      it "can't be instantiated with unknown data" do
        expect { described_class.new(id: 1, name: "Luca", foo: "bar") }.to raise_error(ArgumentError, "unexpected keys [:foo] in Hash input")
      end

      it "can be instantiated with full data" do
        entity = described_class.new(id: 1, name: "Luca")

        expect(entity.id).to   eq(1)
        expect(entity.name).to eq("Luca")
      end

      it 'accepts object that implements #to_hash' do
        entity = described_class.new(input)

        expect(entity.id).to   eq(2)
        expect(entity.name).to eq("MG")
      end

      it 'freezes the intance' do
        entity = described_class.new(id: 1, name: "Luca")

        expect(entity).to be_frozen
      end

      it "fails if values aren't of the expected type" do
        expect { described_class.new(id: "1", name: "Luca") }.to raise_error(TypeError, %("1" (String) has invalid type for :id violates constraints (type?(Integer, "1") failed)))
      end
    end
  end
end
