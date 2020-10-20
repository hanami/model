RSpec.describe Hanami::Entity::Schema::Schemaless do
  let(:subject) { Hanami::Entity::Schema::Schemaless.new }

  describe "#initialize" do
    it "returns frozen instance" do
      expect(subject).to be_frozen
    end
  end

  describe "#call" do
    it "returns empty hash when nil is given" do
      result = subject.call(nil)

      expect(result).to eq({})
    end

    it "returns duped hash" do
      input = { foo: "bar" }
      result = subject.call(input)

      expect(result).to eq(input)
      expect(result.object_id).to_not eq(input.object_id)
    end
  end

  describe "#attribute?" do
    it "always returns true" do
      expect(subject.attribute?(:foo)).to eq(true)
    end
  end
end
