require 'test_helper'

describe Lotus::Model::Config::Adapter do
  describe '#initialize' do
    it 'allows create adapter config' do
      adapter = Lotus::Model::Config::Adapter.new('postgres://localhost/db', :sql)
      adapter.wont_be_nil
    end

    it 'inflects symbol type to adapter class' do
      adapter = Lotus::Model::Config::Adapter.new('postgres://localhost/db', :sql)
      adapter.type.must_equal(Lotus::Model::Adapters::SqlAdapter)
    end

    it 'constantize string type to adapter class' do
      class MyCustomAdapter; end

      adapter = Lotus::Model::Config::Adapter.new('postgres://localhost/db', "MyCustomAdapter")
      adapter.type.must_equal(MyCustomAdapter)
    end
    
    it 'raises FormatError if type is neither String nor Symbol' do
      class MyCustomAdapter; end

      lambda { adapter = Lotus::Model::Config::Adapter.new('postgres://localhost/db', MyCustomAdapter) }
        .must_raise(Lotus::Model::Config::Adapter::FormatError)
    end
  end

end
