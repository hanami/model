# frozen_string_literal: true

RSpec.describe "Hanami::Model::VERSION" do
  it "exposes version" do
    expect(Hanami::Model::VERSION).to eq("1.3.3")
  end
end
