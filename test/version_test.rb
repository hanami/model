require 'test_helper'

describe Hanami::Model::VERSION do
  it 'returns current version' do
    Hanami::Model::VERSION.must_equal '0.6.2.1'
  end
end
