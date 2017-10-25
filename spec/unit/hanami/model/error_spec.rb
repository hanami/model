RSpec.describe Hanami::Model::Error do
  it "inherits from StandardError" do
    expect(described_class.ancestors).to include(StandardError)
  end
end
