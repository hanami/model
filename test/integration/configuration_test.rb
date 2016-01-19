require 'test_helper'

describe 'Configuration DSL' do
  before do
    Hanami::Model.configure do
      adapter type: :memory, uri: 'memory://localhost'

      mapping do
        collection :users do
          entity     User
          repository UserRepository

          attribute :id,   Integer
          attribute :name, String
        end
      end
    end

    Hanami::Model.load!
  end

  after do
    Hanami::Model.unload!
  end

  describe 'when creating new user' do
    before do
      @user = User.new(name: 'Trung')
    end

    it 'add the entity to repositories' do
      @user_counter = UserRepository.all.size

      @user = UserRepository.create(@user)

      users = UserRepository.all
      users.size.must_equal(@user_counter + 1)
      users.first.must_equal(@user)
    end
  end

  describe "when a repository isn't mapped" do
    it 'raises an error when try to use it' do
      exception = -> { UnmappedRepository.find(1) }.must_raise(Hanami::Model::Adapters::NoAdapterError)
      exception.message.must_equal(
        "Cannot invoke `find' on repository. "\
        "Please check if `adapter' and `mapping' are set, "\
        "and that you call `.load!' on the configuration."
      )
    end
  end

  describe 'when mapping is not set' do
    before do
      Hanami::Model.unload!

      Hanami::Model.configure do
        adapter type: :memory, uri: 'memory://localhost'
      end
    end

    it 'raises an error when try to use it' do
      exception = -> { Hanami::Model.load! }.must_raise(Hanami::Model::NoMappingError)
      exception.message.must_equal("Mapping is missing. Please check your framework configuration.")
    end
  end
end
