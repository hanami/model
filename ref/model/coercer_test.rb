require 'test_helper'

describe Hanami::Model::Coercer do
  describe '.load' do
    it 'raises error' do
      -> { Hanami::Model::Coercer.load(23) }.must_raise NotImplementedError
    end
  end

  describe '.dump' do
    it 'raises error' do
      -> { Hanami::Model::Coercer.dump(23) }.must_raise NotImplementedError
    end
  end
end
