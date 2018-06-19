# frozen_string_literal: true

RSpec.describe Hanami::Model::MappedRelation do
  subject { described_class.new(relation) }
  let(:relation) { UserRepository.new(configuration: configuration).users }

  describe "#[]" do
    it "returns attribute" do
      expect(subject[:name]).to be_a_kind_of(ROM::SQL::Attribute)
    end

    it "raises error in case of unknown attribute" do
      expect { subject[:foo] }.to raise_error(Hanami::Model::UnknownAttributeError, ":foo attribute doesn't exist in users schema")
    end
  end
end
