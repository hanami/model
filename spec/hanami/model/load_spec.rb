require "test_helper"

RSpec.describe "Hanami::Model.load!" do
  let(:message) { "Cannot find corresponding type for form" }

  before do
    allow(ROM).to receive(:container) { raise ROM::SQL::UnknownDBTypeError, message }
  end

  it "raises unknown database error when repository automapping spots an unknown type" do
    expect { Hanami::Model.load! }.to raise_error(Hanami::Model::UnknownDatabaseTypeError, message)
  end
end
