RSpec.describe "Hanami::Model::Sql::Types::Schema::Time" do
  let(:described_class) { Hanami::Model::Sql::Types::Schema::Time }

  let(:input) do
    Class.new do
      def to_time
        Time.now
      end
    end.new
  end

  it "returns nil for nil" do
    input = nil
    expect(described_class[input]).to eq(input)
  end

  it "coerces object that respond to #to_time" do
    expect(described_class[input]).to be_within(2).of(input.to_time)
  end

  it "coerces string" do
    time = Time.now
    input = time.to_s

    expect(described_class[input]).to be_within(2).of(time)
  end

  it "coerces Hanami string" do
    input = Hanami::Utils::String.new(Time.now)
    expect(described_class[input]).to be_within(2).of(Time.parse(input))
  end

  it "raises error for meaningless string" do
    input = "foo"
    expect { described_class[input] }
      .to raise_error(ArgumentError, "no time information in #{input.inspect}")
  end

  it "raises error for symbol" do
    input = :foo
    expect { described_class[input] }
      .to raise_error(ArgumentError, "invalid value for Time(): #{input.inspect}")
  end

  it "coerces integer" do
    input = 11
    time = Time.at(input)

    expect(described_class[input]).to be_within(2).of(time)
  end

  it "raises error for float" do
    input = 3.14
    expect { described_class[input] }
      .to raise_error(ArgumentError, "invalid value for Time(): #{input.inspect}")
  end

  it "raises error for bigdecimal" do
    input = BigDecimal(3.14, 10)
    expect { described_class[input] }
      .to raise_error(ArgumentError, "invalid value for Time(): #{input.inspect}")
  end

  it "coerces date" do
    input = Date.today
    time = input.to_time

    expect(described_class[input]).to be_within(2).of(time)
  end

  it "coerces datetime" do
    input = DateTime.new
    time = input.to_time

    expect(described_class[input]).to be_within(2).of(time)
  end

  it "coerces time" do
    input = Time.now
    time = input

    expect(described_class[input]).to be_within(2).of(time)
  end

  it "raises error for array" do
    input = []
    expect { described_class[input] }
      .to raise_error(ArgumentError, "invalid value for Time(): #{input.inspect}")
  end

  it "raises error for hash" do
    input = {}
    expect { described_class[input] }
      .to raise_error(ArgumentError, "invalid value for Time(): #{input.inspect}")
  end
end
