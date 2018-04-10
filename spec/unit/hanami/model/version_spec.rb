RSpec.describe "Hanami::Model::VERSION" do
  it "exposes version" do
    expect(Hanami::Model::VERSION).to eq("1.2.0")
  end
end
