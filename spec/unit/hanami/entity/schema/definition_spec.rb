# frozen_string_literal: true

RSpec.describe Hanami::Entity::Schema::Definition do
  let(:described_class) { Hanami::Entity::Schema::Definition }
  let(:subject) do
    described_class.new do
      attribute :id, Hanami::Model::Types::Coercible::Integer
    end
  end

  describe "#initialize" do
    it "returns frozen instance" do
      subject = described_class.new {}

      expect(subject).to be_frozen
    end

    it "raises error if block isn't given" do
      expect { described_class.new }.to raise_error(LocalJumpError)
    end
  end

  describe "#call" do
    it "returns empty hash when nil is given" do
      result = subject.call(nil)

      expect(result).to eq({})
    end

    it "processes attributes" do
      result = subject.call(id: 1)

      expect(result).to eq(id: 1)
    end

    it "ignores unknown attributes" do
      result = subject.call(foo: "bar")

      expect(result).to eq({})
    end

    it "raises error if the process fails" do
      message = Platform.match do
        engine(:jruby) { "no implicit conversion of Symbol into Integer" }
        default        { "can't convert Symbol into Integer" }
      end

      expect { subject.call(id: :foo) }.to raise_error(TypeError, message)
    end
  end

  describe "#attribute?" do
    it "returns true for known attributes" do
      expect(subject.attribute?(:id)).to eq(true)
    end

    it "returns false for unknown attributes" do
      expect(subject.attribute?(:foo)).to eq(false)
    end
  end
end
