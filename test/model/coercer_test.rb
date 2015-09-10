require 'test_helper'

describe Lotus::Model::Coercer do
  describe '.load' do
    it 'raises error' do
      -> { Lotus::Model::Coercer.load(23) }.must_raise NotImplementedError
    end
  end

  describe '.dump' do
    it 'raises error' do
      -> { Lotus::Model::Coercer.dump(23) }.must_raise NotImplementedError
    end
  end
end
