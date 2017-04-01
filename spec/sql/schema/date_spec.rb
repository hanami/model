require 'test_helper'

RSpec.describe Hanami::Model::Sql::Types::Schema::Date do
  let(:described_class) { Hanami::Model::Sql::Types::Schema::Date }
  let(:input) do
    Class.new do
      def to_date
        Date.today
      end
    end.new
  end

  it 'returns nil for nil' do
    input = nil
    expect(described_class[input]).to eq(input)
  end

  it 'coerces object that respond to #to_date' do
    expect(described_class[input]).to eq(input.to_date)
  end

  it 'coerces string' do
    date = Date.today
    input = date.to_s

    expect(described_class[input]).to eq(date)
  end

  it 'coerces Hanami string' do
    input = Hanami::Utils::String.new(Date.today)
    expect(described_class[input]).to eq(Date.parse(input))
  end

  it 'raises error for meaningless string' do
    input = 'foo'
    expect { described_class[input] }
      .to raise_error(ArgumentError, 'invalid date')
  end

  it 'raises error for symbol' do
    input = :foo
    expect { described_class[input] }
      .to raise_error(ArgumentError, "invalid value for Date(): #{input.inspect}")
  end

  it 'raises error for integer' do
    input = 11
    expect { described_class[input] }
      .to raise_error(ArgumentError, "invalid value for Date(): #{input.inspect}")
  end

  it 'raises error for float' do
    input = 3.14
    expect { described_class[input] }
      .to raise_error(ArgumentError, "invalid value for Date(): #{input.inspect}")
  end

  it 'raises error for bigdecimal' do
    input = BigDecimal.new(3.14, 10)
    expect { described_class[input] }
      .to raise_error(ArgumentError, "invalid value for Date(): #{input.inspect}")
  end

  it 'coerces date' do
    input = Date.today
    date = input

    expect(described_class[input]).to eq(date)
  end

  it 'coerces datetime' do
    input = DateTime.new
    date = input.to_date

    expect(described_class[input]).to eq(date)
  end

  it 'coerces time' do
    input = Time.now
    date = input.to_date

    expect(described_class[input]).to eq(date)
  end

  it 'raises error for array' do
    input = []
    expect { described_class[input] }
      .to raise_error(ArgumentError, "invalid value for Date(): #{input.inspect}")
  end

  it 'raises error for hash' do
    input = {}
    expect { described_class[input] }
      .to raise_error(ArgumentError, "invalid value for Date(): #{input.inspect}")
  end
end
