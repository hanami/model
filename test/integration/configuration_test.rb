require 'test_helper'

describe 'Configuration DSL' do
  before do
    Lotus::Model.configure do
      adapter name: :in_mem, type: :memory, uri: 'memory://localhost'

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

  describe 'when creating new user' do
    before do
      @user = User.new(name: 'Trung')
    end

    it 'add the entity to repositories' do
      @user_counter = UserRepository.all.size

      UserRepository.create(@user)

      users = UserRepository.all
      users.size.must_equal(@user_counter + 1)
      users.first.must_equal(@user)
    end
  end
end
