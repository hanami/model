# frozen_string_literal: true
require "ostruct"

RSpec.describe Hanami::Entity do
  let(:described_class) do
    Class.new(Hanami::Entity)
  end

  describe "equality" do
    it "returns true if same class and same id" do
      entity1 = described_class.new(id: 1)
      entity2 = described_class.new(id: 1)

      expect(entity1).to eq(entity2), "Expected #{entity1.inspect} to equal #{entity2.inspect}"
    end

    it "returns false if same class but different id" do
      entity1 = described_class.new(id: 1)
      entity2 = described_class.new(id: 1000)

      expect(entity1).to_not eq(entity2), "Expected #{entity1.inspect} to NOT equal #{entity2.inspect}"
    end

    it "returns false if different class but same id" do
      entity1 = described_class.new(id: 1)
      entity2 = OpenStruct.new(id: 1)

      expect(entity1).to_not eq(entity2), "Expected #{entity1.inspect} to NOT equal #{entity2.inspect}"
    end

    it "returns false if different class and different id" do
      entity1 = described_class.new(id: 1)
      entity2 = OpenStruct.new(id: 1000)

      expect(entity1).to_not eq(entity2), "Expected #{entity1.inspect} to NOT equal #{entity2.inspect}"
    end

    it "returns true when both the ids are nil" do
      entity1 = described_class.new
      entity2 = described_class.new

      expect(entity1).to eq(entity2), "Expected #{entity1.inspect} to equal #{entity2.inspect}"
    end
  end

  describe "#hash" do
    it "returns predictable object hashing" do
      entity1 = described_class.new(id: 1)
      entity2 = described_class.new(id: 1)

      expect(entity1.hash).to eq(entity2.hash), "Expected #{entity1.hash} to equal #{entity2.hash}"
    end

    it "returns different object hash for same class but different id" do
      entity1 = described_class.new(id: 1)
      entity2 = described_class.new(id: 1000)

      expect(entity1.hash).to_not eq(entity2.hash), "Expected #{entity1.hash} to NOT equal #{entity2.hash}"
    end

    it "returns different object hash for different class but same id" do
      entity1 = described_class.new(id: 1)
      entity2 = Class.new(Hanami::Entity).new(id: 1)

      expect(entity1.hash).to_not eq(entity2.hash), "Expected #{entity1.hash} to NOT equal #{entity2.hash}"
    end

    it "returns different object hash for different class and different id" do
      entity1 = described_class.new(id: 1)
      entity2 = Class.new(Hanami::Entity).new(id: 2)

      expect(entity1.hash).to_not eq(entity2.hash), "Expected #{entity1.hash} to NOT equal #{entity2.hash}"
    end
  end
end
