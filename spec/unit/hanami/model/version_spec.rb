RSpec.describe "Hanami::Model::VERSION" do
  it "exposes version" do
    expect(Hanami::Model::VERSION).to eq("1.1.0.beta3")
  end
end
