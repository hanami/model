require 'test_helper'

describe Hanami::Model::Sql::Types::Schema::Bool do
  let(:described_class) { Hanami::Model::Sql::Types::Schema::Bool }

  it 'returns nil for nil' do
    input = nil
    described_class[input].must_equal input
  end

  it 'returns true for true' do
    input = true
    described_class[input].must_equal input
  end

  it 'returns false for false' do
    input = true
    described_class[input].must_equal input
  end

  it 'raises error for string' do
    input     = 'foo'
    exception = lambda do
      described_class[input]
    end.must_raise(TypeError)

    exception.message.must_equal "#{input.inspect} violates constraints (type?(FalseClass, #{input.inspect}) failed)"
  end

  it 'raises error for symbol' do
    input     = :foo
    exception = lambda do
      described_class[input]
    end.must_raise(TypeError)

    exception.message.must_equal "#{input.inspect} violates constraints (type?(FalseClass, #{input.inspect}) failed)"
  end

  it 'raises error for integer' do
    input     = 11
    exception = lambda do
      described_class[input]
    end.must_raise(TypeError)

    exception.message.must_equal "#{input.inspect} violates constraints (type?(FalseClass, #{input.inspect}) failed)"
  end

  it 'raises error for float' do
    input     = 3.14
    exception = lambda do
      described_class[input]
    end.must_raise(TypeError)

    exception.message.must_equal "#{input.inspect} violates constraints (type?(FalseClass, #{input.inspect}) failed)"
  end

  it 'raises error for bigdecimal' do
    input     = BigDecimal.new(3.14, 10)
    exception = lambda do
      described_class[input]
    end.must_raise(TypeError)

    exception.message.must_equal "#{input.inspect} violates constraints (type?(FalseClass, #{input.inspect}) failed)"
  end

  it 'raises error for date' do
    input     = Date.today
    exception = lambda do
      described_class[input]
    end.must_raise(TypeError)

    exception.message.must_equal "#{input.inspect} violates constraints (type?(FalseClass, #{input.inspect}) failed)"
  end

  it 'raises error for datetime' do
    input     = DateTime.new
    exception = lambda do
      described_class[input]
    end.must_raise(TypeError)

    exception.message.must_equal "#{input.inspect} violates constraints (type?(FalseClass, #{input.inspect}) failed)"
  end

  it 'raises error for time' do
    input     = Time.now
    exception = lambda do
      described_class[input]
    end.must_raise(TypeError)

    exception.message.must_equal "#{input.inspect} violates constraints (type?(FalseClass, #{input.inspect}) failed)"
  end

  it 'raises error for array' do
    input     = []
    exception = lambda do
      described_class[input]
    end.must_raise(TypeError)

    exception.message.must_equal "#{input.inspect} violates constraints (type?(FalseClass, #{input.inspect}) failed)"
  end

  it 'raises error for hash' do
    input     = {}
    exception = lambda do
      described_class[input]
    end.must_raise(TypeError)

    exception.message.must_equal "#{input.inspect} violates constraints (type?(FalseClass, #{input.inspect}) failed)"
  end
end
