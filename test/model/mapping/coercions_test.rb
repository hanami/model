require 'test_helper'

describe Lotus::Model::Mapping::Coercions do
  describe '.Array' do
    it 'converts the input into an array' do
      actual = Lotus::Model::Mapping::Coercions.Array(1)
      actual.must_equal [1]
    end

    it 'returns nil when nil is given' do
      actual = Lotus::Model::Mapping::Coercions.Array(nil)
      actual.must_be_nil
    end
  end

  describe '.Boolean' do
    it 'converts the input into a boolean' do
      actual = Lotus::Model::Mapping::Coercions.Boolean('1')
      actual.must_equal true
    end

    it 'returns nil when nil is given' do
      actual = Lotus::Model::Mapping::Coercions.Boolean(nil)
      actual.must_be_nil
    end
  end

  describe '.Date' do
    it 'converts the input into a date' do
      actual = Lotus::Model::Mapping::Coercions.Date(Date.today)
      actual.must_equal Date.today
    end

    it 'returns nil when nil is given' do
      actual = Lotus::Model::Mapping::Coercions.Date(nil)
      actual.must_be_nil
    end
  end

  describe '.DateTime' do
    it 'converts the input into a datetime' do
      actual = Lotus::Model::Mapping::Coercions.DateTime(DateTime.now)
      actual.to_s.must_equal DateTime.now.to_s
    end

    it 'returns nil when nil is given' do
      actual = Lotus::Model::Mapping::Coercions.DateTime(nil)
      actual.must_be_nil
    end
  end

  describe '.Float' do
    it 'converts the input into a float' do
      actual = Lotus::Model::Mapping::Coercions.Float(1)
      actual.must_equal 1.0
    end

    it 'returns nil when nil is given' do
      actual = Lotus::Model::Mapping::Coercions.Float(nil)
      actual.must_be_nil
    end
  end

  describe '.Hash' do
    it 'converts the input into a hash' do
      actual = Lotus::Model::Mapping::Coercions.Hash([])
      actual.must_equal({})
    end

    it 'returns nil when nil is given' do
      actual = Lotus::Model::Mapping::Coercions.Hash(nil)
      actual.must_be_nil
    end
  end

  describe '.Integer' do
    it 'converts the input into an integer' do
      actual = Lotus::Model::Mapping::Coercions.Integer('23')
      actual.must_equal 23
    end

    it 'returns nil when nil is given' do
      actual = Lotus::Model::Mapping::Coercions.Integer(nil)
      actual.must_be_nil
    end
  end
  
  describe '.BigDecimal' do
    it 'converts the input into an BigDecimal' do
      actual = Lotus::Model::Mapping::Coercions.BigDecimal('23')
      actual.must_equal 23
    end

    it 'returns nil when nil is given' do
      actual = Lotus::Model::Mapping::Coercions.BigDecimal(nil)
      actual.must_be_nil
    end
  end

  describe '.Set' do
    it 'converts the input into a set' do
      actual = Lotus::Model::Mapping::Coercions.Set([1,2])
      actual.must_equal Set.new([1,2])
    end

    it 'returns nil when nil is given' do
      actual = Lotus::Model::Mapping::Coercions.Set(nil)
      actual.must_be_nil
    end
  end

  describe '.String' do
    it 'converts the input into a string' do
      actual = Lotus::Model::Mapping::Coercions.String(12)
      actual.must_equal '12'
    end

    it 'returns nil when nil is given' do
      actual = Lotus::Model::Mapping::Coercions.String(nil)
      actual.must_be_nil
    end
  end

  describe '.Time' do
    it 'converts the input into a string' do
      actual = Lotus::Model::Mapping::Coercions.Time(0)
      actual.must_equal Time.at(0)
    end

    it 'returns nil when nil is given' do
      actual = Lotus::Model::Mapping::Coercions.Time(nil)
      actual.must_be_nil
    end
  end
end
