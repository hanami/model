require 'test_helper'

describe 'Configuration DSL' do
  before do
    Lotus::Model.configure do
      adapter :sqlite3, :sql, SQLITE_CONNECTION_STRING, default: true
      adapter :cache, :memory, 'memory://localhost'

      mapping do
        collection :users do
          entity     User
          repository UserRepository

          attribute :id,   Integer
          attribute :name, String
        end

        adapter :cache do
          collection :users do
            entity     User
            repository CustomUserRepository

            attribute :id,   Integer
            attribute :name, String
          end
        end
      end
    end

    Lotus::Model.load!
  end

  after do
    Lotus::Model.unload!
  end

  describe 'when creating new user' do
    before do
      @user = User.new(name: 'Trung')
    end

    it 'add the entity to repositories via UserRepository' do
      @user_counter = UserRepository.all.size

      UserRepository.create(@user)
      UserRepository.instance_variable_get(:@adapter).must_be_kind_of Lotus::Model::Adapters::SqlAdapter

      users = UserRepository.all
      users.size.must_equal(@user_counter + 1)
      users.first.must_equal(@user)
    end

    it 'add the entity to repositories via CustomUserRepository' do
      @user_counter = CustomUserRepository.all.size

      CustomUserRepository.create(@user)
      CustomUserRepository.instance_variable_get(:@adapter).must_be_kind_of Lotus::Model::Adapters::MemoryAdapter

      users = CustomUserRepository.all
      users.size.must_equal(@user_counter + 1)
      users.first.must_equal(@user)
    end
  end
end
