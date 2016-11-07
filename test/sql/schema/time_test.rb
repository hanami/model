require 'test_helper'

describe Hanami::Model::Sql::Types::Schema::Time do
  let(:described_class) { Hanami::Model::Sql::Types::Schema::Time }
  let(:input) do
    Class.new do
      def to_time
        Time.now
      end
    end.new
  end

  it 'returns nil for nil' do
    input = nil
    described_class[input].must_equal input
  end

  it 'coerces object that respond to #to_time' do
    described_class[input].must_be_close_to(input.to_time, 2)
  end

  it 'coerces string' do
    time  = Time.now
    input = time.to_s

    described_class[input].must_be_close_to(time, 2)
  end

  it 'coerces Hanami string' do
    input = Hanami::Utils::String.new(Time.now)
    described_class[input].must_be_close_to(Time.parse(input), 2)
  end

  it 'raises error for meaningless string' do
    input     = 'foo'
    exception = lambda do
      described_class[input]
    end.must_raise(ArgumentError)

    exception.message.must_equal "no time information in #{input.inspect}"
  end

  it 'raises error for symbol' do
    input     = :foo
    exception = lambda do
      described_class[input]
    end.must_raise(ArgumentError)

    exception.message.must_equal "invalid value for Time(): #{input.inspect}"
  end

  it 'coerces integer' do
    input = 11
    time  = Time.at(input)

    described_class[input].must_be_close_to(time, 2)
  end

  it 'raises error for float' do
    input     = 3.14
    exception = lambda do
      described_class[input]
    end.must_raise(ArgumentError)

    exception.message.must_equal "invalid value for Time(): #{input.inspect}"
  end

  it 'raises error for bigdecimal' do
    input     = BigDecimal.new(3.14, 10)
    exception = lambda do
      described_class[input]
    end.must_raise(ArgumentError)

    exception.message.must_equal "invalid value for Time(): #{input.inspect}"
  end

  it 'coerces date' do
    input = Date.today
    time  = input.to_time

    described_class[input].must_be_close_to(time, 2)
  end

  it 'coerces datetime' do
    input = DateTime.new
    time  = input.to_time

    described_class[input].must_be_close_to(time, 2)
  end

  it 'coerces time' do
    input = Time.now
    time  = input

    described_class[input].must_be_close_to(time, 2)
  end

  it 'raises error for array' do
    input     = []
    exception = lambda do
      described_class[input]
    end.must_raise(ArgumentError)

    exception.message.must_equal "invalid value for Time(): #{input.inspect}"
  end

  it 'raises error for hash' do
    input     = {}
    exception = lambda do
      described_class[input]
    end.must_raise(ArgumentError)

    exception.message.must_equal "invalid value for Time(): #{input.inspect}"
  end
end
