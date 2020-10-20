# frozen_string_literal: true

RSpec.describe Hanami::Model::ForeignKeyConstraintViolationError do
  it "inherits from Hanami::Model::ConstraintViolationError" do
    expect(described_class.ancestors).to include(Hanami::Model::ConstraintViolationError)
  end

  it "has a default error message" do
    expect { raise described_class }.to raise_error(described_class, "Foreign key constraint has been violated")
  end

  it "allows custom error message" do
    expect { raise described_class.new("Ouch") }.to raise_error(described_class, "Ouch")
  end
end
