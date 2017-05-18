require 'test_helper'

describe Hanami::Model::Sql::Types::Schema::Date do
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
    described_class[input].must_be_nil
  end

  it 'coerces object that respond to #to_date' do
    described_class[input].must_equal input.to_date
  end

  it 'coerces string' do
    date  = Date.today
    input = date.to_s

    described_class[input].must_equal date
  end

  it 'coerces Hanami string' do
    input = Hanami::Utils::String.new(Date.today)
    described_class[input].must_equal Date.parse(input)
  end

  it 'raises error for meaningless string' do
    input     = 'foo'
    exception = lambda do
      described_class[input]
    end.must_raise(ArgumentError)

    exception.message.must_equal 'invalid date'
  end

  it 'raises error for symbol' do
    input     = :foo
    exception = lambda do
      described_class[input]
    end.must_raise(ArgumentError)

    exception.message.must_equal "invalid value for Date(): #{input.inspect}"
  end

  it 'raises error for integer' do
    input     = 11
    exception = lambda do
      described_class[input]
    end.must_raise(ArgumentError)

    exception.message.must_equal "invalid value for Date(): #{input.inspect}"
  end

  it 'raises error for float' do
    input     = 3.14
    exception = lambda do
      described_class[input]
    end.must_raise(ArgumentError)

    exception.message.must_equal "invalid value for Date(): #{input.inspect}"
  end

  it 'raises error for bigdecimal' do
    input     = BigDecimal.new(3.14, 10)
    exception = lambda do
      described_class[input]
    end.must_raise(ArgumentError)

    exception.message.must_equal "invalid value for Date(): #{input.inspect}"
  end

  it 'coerces date' do
    input = Date.today
    date  = input

    described_class[input].must_equal date
  end

  it 'coerces datetime' do
    input = DateTime.new
    date  = input.to_date

    described_class[input].must_equal date
  end

  it 'coerces time' do
    input = Time.now
    date  = input.to_date

    described_class[input].must_equal date
  end

  it 'raises error for array' do
    input     = []
    exception = lambda do
      described_class[input]
    end.must_raise(ArgumentError)

    exception.message.must_equal "invalid value for Date(): #{input.inspect}"
  end

  it 'raises error for hash' do
    input     = {}
    exception = lambda do
      described_class[input]
    end.must_raise(ArgumentError)

    exception.message.must_equal "invalid value for Date(): #{input.inspect}"
  end
end
