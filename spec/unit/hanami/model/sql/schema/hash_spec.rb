# frozen_string_literal: true

RSpec.describe "Hanami::Model::Sql::Types::Schema::Hash" do
  let(:described_class) { Hanami::Model::Sql::Types::Schema::Hash }

  let(:input) do
    Class.new do
      def to_hash
        Hash[]
      end
    end.new
  end

  it "returns nil for nil" do
    input = nil
    expect(described_class[input]).to eq(input)
  end

  it "coerces object that respond to #to_hash" do
    expect(described_class[input]).to eq(input.to_hash)
  end

  it "coerces string" do
    input = "foo"
    expect { described_class[input] }
      .to raise_error(Dry::Types::ConstraintError, "#{input.inspect} violates constraints (invalid value for Hash(): #{input.inspect} failed)")
  end

  it "raises error for symbol" do
    input = :foo
    expect { described_class[input] }
      .to raise_error(Dry::Types::ConstraintError, "#{input.inspect} violates constraints (invalid value for Hash(): #{input.inspect} failed)")
  end

  it "raises error for integer" do
    input = 11
    expect { described_class[input] }
      .to raise_error(Dry::Types::ConstraintError, "#{input.inspect} violates constraints (invalid value for Hash(): #{input.inspect} failed)")
  end

  it "raises error for float" do
    input = 3.14
    expect { described_class[input] }
      .to raise_error(Dry::Types::ConstraintError, "#{input.inspect} violates constraints (invalid value for Hash(): #{input.inspect} failed)")
  end

  it "raises error for bigdecimal" do
    input = BigDecimal(3.14, 10)
    expect { described_class[input] }
      .to raise_error(Dry::Types::ConstraintError, "#{input.inspect} violates constraints (invalid value for Hash(): #{input.inspect} failed)")
  end

  it "raises error for date" do
    input = Date.today
    expect { described_class[input] }
      .to raise_error(Dry::Types::ConstraintError, "#{input.inspect} violates constraints (invalid value for Hash(): #{input.inspect} failed)")
  end

  it "raises error for datetime" do
    input = DateTime.new
    expect { described_class[input] }
      .to raise_error(Dry::Types::ConstraintError, "#{input.inspect} violates constraints (invalid value for Hash(): #{input.inspect} failed)")
  end

  it "raises error for time" do
    input = Time.now
    expect { described_class[input] }
      .to raise_error(Dry::Types::ConstraintError, "#{input.inspect} violates constraints (invalid value for Hash(): #{input.inspect} failed)")
  end

  it "raises error for array" do
    input = []
    expect { described_class[input] }
      .to raise_error(Dry::Types::ConstraintError, "#{input.inspect} violates constraints (invalid value for Hash(): #{input.inspect} failed)")
  end

  it "coerces hash" do
    input = {}
    expect(described_class[input]).to eq(input)
  end
end
