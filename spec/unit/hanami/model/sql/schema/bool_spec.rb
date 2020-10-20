# frozen_string_literal: true
RSpec.describe "Hanami::Model::Sql::Types::Schema::Bool" do
  let(:described_class) { Hanami::Model::Sql::Types::Schema::Bool }

  it "returns nil for nil" do
    input = nil
    expect(described_class[input]).to eq(input)
  end

  it "returns true for true" do
    input = true
    expect(described_class[input]).to eq(input)
  end

  it "returns false for false" do
    input = true
    expect(described_class[input]).to eq(input)
  end

  it "raises error for string" do
    input = "foo"
    expect { described_class[input] }
      .to raise_error(TypeError, "#{input.inspect} violates constraints (type?(FalseClass, #{input.inspect}) failed)")
  end

  it "raises error for symbol" do
    input = :foo
    expect { described_class[input] }
      .to raise_error(TypeError, "#{input.inspect} violates constraints (type?(FalseClass, #{input.inspect}) failed)")
  end

  it "raises error for integer" do
    input = 11
    expect { described_class[input] }
      .to raise_error(TypeError, "#{input.inspect} violates constraints (type?(FalseClass, #{input.inspect}) failed)")
  end

  it "raises error for float" do
    input = 3.14
    expect { described_class[input] }
      .to raise_error(TypeError, "#{input.inspect} violates constraints (type?(FalseClass, #{input.inspect}) failed)")
  end

  it "raises error for bigdecimal" do
    input = BigDecimal(3.14, 10)
    expect { described_class[input] }
      .to raise_error(TypeError, "#{input.inspect} violates constraints (type?(FalseClass, #{input.inspect}) failed)")
  end

  it "raises error for date" do
    input = Date.today
    expect { described_class[input] }
      .to raise_error(TypeError, "#{input.inspect} violates constraints (type?(FalseClass, #{input.inspect}) failed)")
  end

  it "raises error for datetime" do
    input = DateTime.new
    expect { described_class[input] }
      .to raise_error(TypeError, "#{input.inspect} violates constraints (type?(FalseClass, #{input.inspect}) failed)")
  end

  it "raises error for time" do
    input = Time.now
    expect { described_class[input] }
      .to raise_error(TypeError, "#{input.inspect} violates constraints (type?(FalseClass, #{input.inspect}) failed)")
  end

  it "raises error for array" do
    input = []
    expect { described_class[input] }
      .to raise_error(TypeError, "#{input.inspect} violates constraints (type?(FalseClass, #{input.inspect}) failed)")
  end

  it "raises error for hash" do
    input = {}
    expect { described_class[input] }
      .to raise_error(TypeError, "#{input.inspect} violates constraints (type?(FalseClass, #{input.inspect}) failed)")
  end
end
