require 'test_helper'

describe Hanami::Model::Sql::Types::Schema::Array do
  let(:described_class) { Hanami::Model::Sql::Types::Schema::Array }
  let(:input) do
    Class.new do
      def to_ary
        []
      end
    end.new
  end

  it 'returns nil for nil' do
    input = nil
    described_class[input].must_be_nil
  end

  it 'coerces object that respond to #to_ary' do
    described_class[input].must_equal input.to_ary
  end

  it 'coerces string' do
    input     = 'foo'
    exception = lambda do
      described_class[input]
    end.must_raise(ArgumentError)

    exception.message.must_equal "invalid value for Array(): #{input.inspect}"
  end

  it 'raises error for symbol' do
    input     = :foo
    exception = lambda do
      described_class[input]
    end.must_raise(ArgumentError)

    exception.message.must_equal "invalid value for Array(): #{input.inspect}"
  end

  it 'raises error for integer' do
    input     = 11
    exception = lambda do
      described_class[input]
    end.must_raise(ArgumentError)

    exception.message.must_equal "invalid value for Array(): #{input.inspect}"
  end

  it 'raises error for float' do
    input     = 3.14
    exception = lambda do
      described_class[input]
    end.must_raise(ArgumentError)

    exception.message.must_equal "invalid value for Array(): #{input.inspect}"
  end

  it 'raises error for bigdecimal' do
    input     = BigDecimal.new(3.14, 10)
    exception = lambda do
      described_class[input]
    end.must_raise(ArgumentError)

    exception.message.must_equal "invalid value for Array(): #{input.inspect}"
  end

  it 'raises error for date' do
    input     = Date.today
    exception = lambda do
      described_class[input]
    end.must_raise(ArgumentError)

    exception.message.must_equal "invalid value for Array(): #{input.inspect}"
  end

  it 'raises error for datetime' do
    input     = DateTime.new
    exception = lambda do
      described_class[input]
    end.must_raise(ArgumentError)

    exception.message.must_equal "invalid value for Array(): #{input.inspect}"
  end

  it 'raises error for time' do
    input     = Time.now
    exception = lambda do
      described_class[input]
    end.must_raise(ArgumentError)

    exception.message.must_equal "invalid value for Array(): #{input.inspect}"
  end

  it 'coerces array' do
    input = []
    described_class[input].must_equal input
  end

  it 'raises error for hash' do
    input     = {}
    exception = lambda do
      described_class[input]
    end.must_raise(ArgumentError)

    exception.message.must_equal "invalid value for Array(): #{input.inspect}"
  end
end
