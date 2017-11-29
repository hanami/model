# frozen_string_literal: true

RSpec.describe "Hanami::Model::VERSION" do
  it "exposes version" do
    expect(Hanami::Model::VERSION).to eq("2.0.0.alpha1")
  end
end
