# frozen_string_literal: true
RSpec.describe "Hanami::Model::Sql::Types::Schema::DateTime" do
  let(:described_class) { Hanami::Model::Sql::Types::Schema::DateTime }

  let(:input) do
    Class.new do
      def to_datetime
        DateTime.new
      end
    end.new
  end

  it "returns nil for nil" do
    input = nil
    expect(described_class[input]).to eq(input)
  end

  it "coerces object that respond to #to_datetime" do
    expect(described_class[input]).to eq(input.to_datetime)
  end

  it "coerces string" do
    date = DateTime.new
    input = date.to_s

    expect(described_class[input]).to eq(date)
  end

  it "coerces Hanami string" do
    input = Hanami::Utils::String.new(DateTime.new)
    expect(described_class[input]).to eq(DateTime.parse(input))
  end

  it "raises error for meaningless string" do
    input = "foo"
    expect { described_class[input] }
      .to raise_error(ArgumentError, "invalid date")
  end

  it "raises error for symbol" do
    input = :foo
    expect { described_class[input] }
      .to raise_error(ArgumentError, "invalid value for DateTime(): #{input.inspect}")
  end

  it "raises error for integer" do
    input = 11
    expect { described_class[input] }
      .to raise_error(ArgumentError, "invalid value for DateTime(): #{input.inspect}")
  end

  it "raises error for float" do
    input = 3.14
    expect { described_class[input] }
      .to raise_error(ArgumentError, "invalid value for DateTime(): #{input.inspect}")
  end

  it "raises error for bigdecimal" do
    input = BigDecimal(3.14, 10)
    expect { described_class[input] }
      .to raise_error(ArgumentError, "invalid value for DateTime(): #{input.inspect}")
  end

  it "coerces date" do
    input = Date.today
    date_time = input.to_datetime

    expect(described_class[input]).to eq(date_time)
  end

  it "coerces datetime" do
    input = DateTime.new
    date_time = input

    expect(described_class[input]).to eq(date_time)
  end

  it "coerces time" do
    input = Time.now
    date_time = input.to_datetime

    expect(described_class[input]).to be_within(2).of(date_time)
  end

  it "raises error for array" do
    input = []
    expect { described_class[input] }
      .to raise_error(ArgumentError, "invalid value for DateTime(): #{input.inspect}")
  end

  it "raises error for hash" do
    input = {}
    expect { described_class[input] }
      .to raise_error(ArgumentError, "invalid value for DateTime(): #{input.inspect}")
  end
end
