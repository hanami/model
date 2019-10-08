# frozen_string_literal: true

RSpec.describe "Hanami::Model::Sql::Types::Schema::Decimal" do
  let(:described_class) { Hanami::Model::Sql::Types::Schema::Decimal }

  let(:input) do
    Class.new do
      def to_d
        BigDecimal(10)
      end
    end.new
  end

  it "returns nil for nil" do
    input = nil
    expect(described_class[input]).to eq(input)
  end

  it "coerces object that respond to #to_d" do
    expect(described_class[input]).to eq(input.to_d)
  end

  it "coerces string representing int" do
    input = "1"
    expect(described_class[input]).to eq(input.to_d)
  end

  it "coerces Hanami string representing int" do
    input = Hanami::Utils::String.new("1")
    expect(described_class[input]).to eq(input.to_d)
  end

  it "coerces string representing float" do
    input = "3.14"
    expect(described_class[input]).to eq(input.to_d)
  end

  it "coerces Hanami string representing float" do
    input = Hanami::Utils::String.new("3.14")
    expect(described_class[input]).to eq(input.to_d)
  end

  it "raises error for symbol" do
    input = :house_11
    expect { described_class[input] }
      .to raise_error(Dry::Types::CoercionError, "invalid value for BigDecimal(): #{input.inspect}")
  end

  it "coerces integer" do
    input = 23
    expect(described_class[input]).to eq(input.to_d)
  end

  it "coerces float" do
    input = 3.14
    expect(described_class[input]).to eq(input.to_d)
  end

  it "coerces bigdecimal" do
    input = BigDecimal(3.14, 10)
    expect(described_class[input]).to eq(input.to_d)
  end

  it "raises error for date" do
    input = Date.today
    expect { described_class[input] }
      .to raise_error(Dry::Types::CoercionError, "invalid value for BigDecimal(): #{input.inspect}")
  end

  it "raises error for datetime" do
    input = DateTime.new
    expect { described_class[input] }
      .to raise_error(Dry::Types::CoercionError, "invalid value for BigDecimal(): #{input.inspect}")
  end

  it "raises error for time" do
    input = Time.now
    expect { described_class[input] }
      .to raise_error(Dry::Types::CoercionError, "invalid value for BigDecimal(): #{input.inspect}")
  end

  it "raises error for array" do
    input = []
    expect { described_class[input] }
      .to raise_error(Dry::Types::CoercionError, "invalid value for BigDecimal(): #{input.inspect}")
  end

  it "raises error for hash" do
    input = {}
    expect { described_class[input] }
      .to raise_error(Dry::Types::CoercionError, "invalid value for BigDecimal(): #{input.inspect}")
  end
end
