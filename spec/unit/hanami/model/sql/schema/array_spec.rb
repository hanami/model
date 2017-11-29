# frozen_string_literal: true

RSpec.describe "Hanami::Model::Sql::Types::Schema::Array" do
  let(:described_class) { Hanami::Model::Sql::Types::Schema::Array }

  let(:input) do
    Class.new do
      def to_ary
        []
      end
    end.new
  end

  it "returns nil for nil" do
    input = nil
    expect(described_class[input]).to eq(input)
  end

  it "coerces object that respond to #to_ary" do
    expect(described_class[input]).to eq(input.to_ary)
  end

  it "coerces string" do
    input = "foo"
    expect { described_class[input] }
      .to raise_error(ArgumentError, "invalid value for Array(): #{input.inspect}")
  end

  it "raises error for symbol" do
    input = :foo
    expect { described_class[input] }
      .to raise_error(ArgumentError, "invalid value for Array(): #{input.inspect}")
  end

  it "raises error for integer" do
    input = 11
    expect { described_class[input] }
      .to raise_error(ArgumentError, "invalid value for Array(): #{input.inspect}")
  end

  it "raises error for float" do
    input = 3.14
    expect { described_class[input] }
      .to raise_error(ArgumentError, "invalid value for Array(): #{input.inspect}")
  end

  it "raises error for bigdecimal" do
    input = BigDecimal.new(3.14, 10)
    expect { described_class[input] }
      .to raise_error(ArgumentError, "invalid value for Array(): #{input.inspect}")
  end

  it "raises error for date" do
    input = Date.today
    expect { described_class[input] }
      .to raise_error(ArgumentError, "invalid value for Array(): #{input.inspect}")
  end

  it "raises error for datetime" do
    input = DateTime.new
    expect { described_class[input] }
      .to raise_error(ArgumentError, "invalid value for Array(): #{input.inspect}")
  end

  it "raises error for time" do
    input = Time.now
    expect { described_class[input] }
      .to raise_error(ArgumentError, "invalid value for Array(): #{input.inspect}")
  end

  it "coerces array" do
    input = []
    expect(described_class[input]).to eq(input)
  end

  it "raises error for hash" do
    input = {}
    expect { described_class[input] }
      .to raise_error(ArgumentError, "invalid value for Array(): #{input.inspect}")
  end
end
