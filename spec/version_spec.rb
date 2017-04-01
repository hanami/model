require 'test_helper'

RSpec.describe Hanami::Model::VERSION do
  it 'exposes version' do
    expect(Hanami::Model::VERSION).to eq('1.0.0.rc1')
  end
end
