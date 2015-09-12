require 'test_helper'

SIGNATURE_METHODS = %w(load dump).freeze

describe Lotus::Model::Mapping::Coercers::Array do
  SIGNATURE_METHODS.each do |m|
    describe ".#{ m }" do
      it 'converts the input into an array' do
        actual = Lotus::Model::Mapping::Coercers::Array.__send__(m, 1)
        actual.must_equal [1]
      end

      it 'returns nil when nil is given' do
        actual = Lotus::Model::Mapping::Coercers::Array.__send__(m, nil)
        actual.must_be_nil
      end

      it 'preserves data structure' do
        actual = Lotus::Model::Mapping::Coercers::Array.__send__(m, expected = [['lotus-controller', '~> 0.4'], ['lotus-view', '~> 0.4']])
        actual.must_equal expected
      end
    end
  end
end

describe Lotus::Model::Mapping::Coercers::Boolean do
  SIGNATURE_METHODS.each do |m|
    describe ".#{ m }" do
      it 'converts the input into a boolean' do
        actual = Lotus::Model::Mapping::Coercers::Boolean.__send__(m, '1')
        actual.must_equal true
      end

      it 'returns nil when nil is given' do
        actual = Lotus::Model::Mapping::Coercers::Boolean.__send__(m, nil)
        actual.must_be_nil
      end
    end
  end
end

describe Lotus::Model::Mapping::Coercers::Date do
  SIGNATURE_METHODS.each do |m|
    describe ".#{ m }" do
      it 'converts the input into a date' do
        actual = Lotus::Model::Mapping::Coercers::Date.__send__(m, Date.today)
        actual.must_equal Date.today
      end

      it 'returns nil when nil is given' do
        actual = Lotus::Model::Mapping::Coercers::Date.__send__(m, nil)
        actual.must_be_nil
      end
    end
  end
end

describe Lotus::Model::Mapping::Coercers::DateTime do
  SIGNATURE_METHODS.each do |m|
    describe ".#{ m }" do
      it 'converts the input into a datetime' do
        actual = Lotus::Model::Mapping::Coercers::DateTime.__send__(m, DateTime.now)
        actual.to_s.must_equal DateTime.now.to_s
      end

      it 'returns nil when nil is given' do
        actual = Lotus::Model::Mapping::Coercers::DateTime.__send__(m, nil)
        actual.must_be_nil
      end
    end
  end
end

describe Lotus::Model::Mapping::Coercers::Float do
  SIGNATURE_METHODS.each do |m|
    describe ".#{ m }" do
      it 'converts the input into a float' do
        actual = Lotus::Model::Mapping::Coercers::Float.__send__(m, 1)
        actual.must_equal 1.0
      end

      it 'returns nil when nil is given' do
        actual = Lotus::Model::Mapping::Coercers::Float.__send__(m, nil)
        actual.must_be_nil
      end
    end
  end
end

describe Lotus::Model::Mapping::Coercers::Hash do
  SIGNATURE_METHODS.each do |m|
    describe ".#{ m }" do
      it 'converts the input into a hash' do
        actual = Lotus::Model::Mapping::Coercers::Hash.__send__(m, [])
        actual.must_equal({})
      end

      it 'returns nil when nil is given' do
        actual = Lotus::Model::Mapping::Coercers::Hash.__send__(m, nil)
        actual.must_be_nil
      end
    end
  end
end

describe Lotus::Model::Mapping::Coercers::Integer do
  SIGNATURE_METHODS.each do |m|
    describe ".#{ m }" do
      it 'converts the input into an integer' do
        actual = Lotus::Model::Mapping::Coercers::Integer.__send__(m, '23')
        actual.must_equal 23
      end

      it 'returns nil when nil is given' do
        actual = Lotus::Model::Mapping::Coercers::Integer.__send__(m, nil)
        actual.must_be_nil
      end
    end
  end
end

describe Lotus::Model::Mapping::Coercers::BigDecimal do
  SIGNATURE_METHODS.each do |m|
    describe ".#{ m }" do
      it 'converts the input into a BigDecimal' do
        actual = Lotus::Model::Mapping::Coercers::BigDecimal.__send__(m, '23')
        actual.must_equal BigDecimal.new(23)
      end

      it 'returns nil when nil is given' do
        actual = Lotus::Model::Mapping::Coercers::BigDecimal.__send__(m, nil)
        actual.must_be_nil
      end
    end
  end
end

describe Lotus::Model::Mapping::Coercers::Set do
  SIGNATURE_METHODS.each do |m|
    describe ".#{ m }" do
      it 'converts the input into a set' do
        actual = Lotus::Model::Mapping::Coercers::Set.__send__(m, [1,1])
        actual.must_equal Set.new([1])
      end

      it 'returns nil when nil is given' do
        actual = Lotus::Model::Mapping::Coercers::Set.__send__(m, nil)
        actual.must_be_nil
      end
    end
  end
end

describe Lotus::Model::Mapping::Coercers::String do
  SIGNATURE_METHODS.each do |m|
    describe ".#{ m }" do
      it 'converts the input into a string' do
        actual = Lotus::Model::Mapping::Coercers::String.__send__(m, 12)
        actual.must_equal '12'
      end

      it 'returns nil when nil is given' do
        actual = Lotus::Model::Mapping::Coercers::String.__send__(m, nil)
        actual.must_be_nil
      end
    end
  end
end

describe Lotus::Model::Mapping::Coercers::Symbol do
  SIGNATURE_METHODS.each do |m|
    describe ".#{ m }" do
      it 'converts the input into a symbol' do
        actual = Lotus::Model::Mapping::Coercers::Symbol.__send__(m, 'wat')
        actual.must_equal :wat
      end

      it 'returns nil when nil is given' do
        actual = Lotus::Model::Mapping::Coercers::Symbol.__send__(m, nil)
        actual.must_equal nil
      end
    end
  end
end

describe Lotus::Model::Mapping::Coercers::Time do
  SIGNATURE_METHODS.each do |m|
    describe ".#{ m }" do
      it 'converts the input into a string' do
        actual = Lotus::Model::Mapping::Coercers::Time.__send__(m, 0)
        actual.must_equal Time.at(0)
      end

      it 'returns nil when nil is given' do
        actual = Lotus::Model::Mapping::Coercers::Time.__send__(m, nil)
        actual.must_be_nil
      end
    end
  end
end
