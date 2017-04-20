require 'test_helper'

describe Hanami::Model::Sql::Types::Schema::String do
  let(:described_class) { Hanami::Model::Sql::Types::Schema::String }

  it 'returns nil for nil' do
    input = nil
    described_class[input].must_be_nil
  end

  it 'coerces string' do
    input = 'foo'
    described_class[input].must_equal input.to_s
  end

  it 'coerces symbol' do
    input = :foo
    described_class[input].must_equal input.to_s
  end

  it 'coerces integer' do
    input = 23
    described_class[input].must_equal input.to_s
  end

  it 'coerces float' do
    input = 3.14
    described_class[input].must_equal input.to_s
  end

  it 'coerces bigdecimal' do
    input = BigDecimal.new(3.14, 10)
    described_class[input].must_equal input.to_s
  end

  it 'coerces date' do
    input = Date.today
    described_class[input].must_equal input.to_s
  end

  it 'coerces datetime' do
    input = DateTime.new
    described_class[input].must_equal input.to_s
  end

  it 'coerces time' do
    input = Time.now
    described_class[input].must_equal input.to_s
  end

  it 'coerces array' do
    input = []
    described_class[input].must_equal input.to_s
  end

  it 'coerces hash' do
    input = {}
    described_class[input].must_equal input.to_s
  end
end
