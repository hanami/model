require 'test_helper'

describe Hanami::Model::Sql::Types::Schema::DateTime do
  let(:described_class) { Hanami::Model::Sql::Types::Schema::DateTime }
  let(:input) do
    Class.new do
      def to_datetime
        DateTime.new
      end
    end.new
  end

  it 'returns nil for nil' do
    input = nil
    described_class[input].must_equal input
  end

  it 'coerces object that respond to #to_datetime' do
    described_class[input].must_equal input.to_datetime
  end

  it 'coerces string' do
    date  = DateTime.new
    input = date.to_s

    described_class[input].must_equal date
  end

  it 'coerces Hanami string' do
    input = Hanami::Utils::String.new(DateTime.new)
    described_class[input].must_equal DateTime.parse(input)
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

    exception.message.must_equal "invalid value for DateTime(): #{input.inspect}"
  end

  it 'raises error for integer' do
    input     = 11
    exception = lambda do
      described_class[input]
    end.must_raise(ArgumentError)

    exception.message.must_equal "invalid value for DateTime(): #{input.inspect}"
  end

  it 'raises error for float' do
    input     = 3.14
    exception = lambda do
      described_class[input]
    end.must_raise(ArgumentError)

    exception.message.must_equal "invalid value for DateTime(): #{input.inspect}"
  end

  it 'raises error for bigdecimal' do
    input     = BigDecimal.new(3.14, 10)
    exception = lambda do
      described_class[input]
    end.must_raise(ArgumentError)

    exception.message.must_equal "invalid value for DateTime(): #{input.inspect}"
  end

  it 'coerces date' do
    input     = Date.today
    date_time = input.to_datetime

    described_class[input].must_equal date_time
  end

  it 'coerces datetime' do
    input     = DateTime.new
    date_time = input

    described_class[input].must_equal date_time
  end

  it 'coerces time' do
    input     = Time.now
    date_time = input.to_datetime

    described_class[input].must_be_close_to(date_time, 2)
  end

  it 'raises error for array' do
    input     = []
    exception = lambda do
      described_class[input]
    end.must_raise(ArgumentError)

    exception.message.must_equal "invalid value for DateTime(): #{input.inspect}"
  end

  it 'raises error for hash' do
    input     = {}
    exception = lambda do
      described_class[input]
    end.must_raise(ArgumentError)

    exception.message.must_equal "invalid value for DateTime(): #{input.inspect}"
  end
end
