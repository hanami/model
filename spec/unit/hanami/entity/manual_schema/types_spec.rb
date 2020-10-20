# frozen_string_literal: true
RSpec.describe Hanami::Entity do
  describe "manual schema (types)" do
    [nil, :schema, :strict, :weak, :permissive, :strict_with_defaults, :symbolized].each do |type|
      it "allows to build schema with #{type.inspect}" do
        Class.new(described_class) do
          attributes(type) {}
        end
      end
    end

    it "raises error for unknown type" do
      expect do
        Class.new(described_class) do
          attributes(:unknown) {}
        end
      end.to raise_error(Hanami::Model::Error, "Unknown schema type: `:unknown'")
    end
  end
end
