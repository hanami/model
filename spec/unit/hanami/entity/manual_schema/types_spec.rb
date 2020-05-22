# frozen_string_literal: true

RSpec.describe Hanami::Entity, skip: true do
  describe "manual schema (types)" do
    %i[strict struct].each do |type|
      it "allows to build schema with #{type.inspect}" do
        Class.new(described_class[type])
      end
    end

    it "raises error for unknown type" do
      [nil, :unknown].each do |type|
        expect do
          Class.new(described_class[type])
        end.to raise_error(Hanami::Model::Error, "Unknown schema type: `#{type.inspect}'")
      end
    end
  end
end
