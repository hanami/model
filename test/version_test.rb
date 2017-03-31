require 'test_helper'

describe Hanami::Model::VERSION do
  it 'exposes version' do
    Hanami::Model::VERSION.must_equal '1.0.0.rc1'
  end
end
