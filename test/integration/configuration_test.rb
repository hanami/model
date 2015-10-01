require 'test_helper'

describe 'Configuration DSL' do
  describe 'when creating new user' do
    before do
      Lotus::Model.configure do
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

      Lotus::Model.load!
    end

    after do
      Lotus::Model.unload!
    end

    let(:user) { User.new(name: 'John Doe') }

    it 'add the entity to repositories' do
      @user_counter = UserRepository.all.size

      persisted_user = UserRepository.create(user)

      users = UserRepository.all
      users.first.must_equal(persisted_user)
      users.size.must_equal(@user_counter + 1)
    end
  end

  describe "when a repository isn't mapped" do
    it 'raises an error when try to use it' do
      exception = -> { UnmappedRepository.find(1) }.must_raise(Lotus::Model::Adapters::NoAdapterError)
      exception.message.must_equal("Cannot invoke `find' without selecting an adapter. Please check your framework configuration.")
    end
  end

  describe 'when mapping is not set' do
    before do
      Lotus::Model.configure do
        adapter type: :memory, uri: 'memory://localhost'
      end
    end

    it 'raises an error when try to use it' do
      exception = -> { Lotus::Model.load! }.must_raise(Lotus::Model::NoMappingError)
      exception.message.must_equal("Mapping is missing. Please check your framework configuration.")
    end
  end
end
