RSpec.describe Hanami::Model::ConstraintViolationError do
  it "inherits from Hanami::Model::Error" do
    expect(described_class.ancestors).to include(Hanami::Model::Error)
  end

  it "has a default error message" do
    expect { raise described_class }.to raise_error(described_class, "Constraint has been violated")
  end

  it "allows custom error message" do
    expect { raise described_class.new("Ouch") }.to raise_error(described_class, "Ouch")
  end
end
