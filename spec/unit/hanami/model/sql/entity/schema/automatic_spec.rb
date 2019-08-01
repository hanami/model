# frozen_string_literal: true

RSpec.describe Hanami::Model::Sql::Entity::Schema do
  describe "automatic" do
    subject { entity.schema }
    let(:entity) { Author }

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

      it "processes attributes" do
        now = Time.now
        result = subject.call(id: 1, created_at: now.to_s)

        expect(result.fetch(:id)).to eq(1)
        expect(result.fetch(:created_at)).to be_within(2).of(now)
      end

      it "ignores unknown attributes" do
        result = subject.call(foo: "bar")

        expect(result).to eq({})
      end
    end

    describe "#has_attribute?" do
      it "returns true for known attributes" do
        expect(entity.has_attribute?(:id)).to eq(true)
      end

      it "returns false for unknown attributes" do
        expect(entity.has_attribute?(:foo)).to eq(false)
      end
    end
  end
end
