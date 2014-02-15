require 'test_helper'

describe Lotus::Model::Repository do
  let(:user1) { User.new(name: 'L') }
  let(:user2) { User.new(name: 'MG') }
  let(:users) { [user1, user2] }

  let(:article) { Article.new(title: 'Introducing Lotus::Model') }

  before do
    UserRepository.clear
    ArticleRepository.clear
  end

  describe '.persist' do
    describe 'when new record' do
      before do
        UserRepository.persist(user)
      end

      let(:user) { User.new(name: 'S') }

      it 'is created' do
        id = UserRepository.last.id
        UserRepository.find(id).must_equal(user)
      end
    end

    describe 'when already persisted' do
      before do
        UserRepository.create(user1)

        user1.name = 'Luke'
        UserRepository.persist(user1)
      end

      let(:id) { user1.id }

      it 'is updated' do
        UserRepository.find(id).must_equal(user1)
      end
    end
  end

  describe '.create' do
    before do
      UserRepository.create(user1)
      UserRepository.create(user2)
    end

    it 'creates records' do
      UserRepository.all.must_equal(users)
    end

    it 'creates different kind of records' do
      ArticleRepository.create(article)
      ArticleRepository.all.must_equal([article])
    end
  end

  describe '.update' do
    before do
      UserRepository.create(user1)
    end

    let(:id) { user1.id }

    it 'updates records' do
      user = User.new(name: 'Luca')
      user.id = id

      UserRepository.update(user)

      u = UserRepository.find(id)
      u.name.must_equal('Luca')
    end
  end

  describe '.delete' do
    before do
      UserRepository.create(user)
      UserRepository.delete(user)
    end

    let(:user) { User.new(name: 'D') }

    it 'delete entity' do
      UserRepository.all.wont_include(user)
    end
  end

  describe '.all' do
    describe 'without data' do
      it 'returns an empty collection' do
        UserRepository.all.must_be_empty
      end
    end

    describe 'with data' do
      before do
        UserRepository.create(user1)
        UserRepository.create(user2)
      end

      it 'returns all the records' do
        UserRepository.all.must_equal(users)
      end
    end
  end

  describe '.find' do
    describe 'without data' do
      it 'returns nil' do
        UserRepository.find(1).must_be_nil
      end
    end

    describe 'with data' do
      before do
        UserRepository.create(user1)
        UserRepository.create(user2)
      end

      it 'returns the record associated with the given id' do
        UserRepository.find(user1.id).must_equal(user1)
        UserRepository.find(user2.id.to_s).must_equal(user2)
      end
    end
  end

  describe '.first' do
    describe 'without data' do
      it 'returns nil' do
        UserRepository.first.must_be_nil
      end
    end

    describe 'with data' do
      before do
        UserRepository.create(user1)
        UserRepository.create(user2)
      end

      it 'returns first record' do
        UserRepository.first.must_equal(user1)
      end
    end
  end

  describe '.last' do
    describe 'without data' do
      it 'returns nil' do
        UserRepository.last.must_be_nil
      end
    end

    describe 'with data' do
      before do
        UserRepository.create(user1)
        UserRepository.create(user2)
      end

      it 'returns last record' do
        UserRepository.last.must_equal(user2)
      end
    end
  end

  describe '.clear' do
    describe 'without data' do
      it 'removes all the records' do
        UserRepository.clear
        UserRepository.all.must_be_empty
      end
    end

    describe 'with data' do
      before do
        UserRepository.create(user1)
        UserRepository.create(user2)
      end

      it 'removes all the records' do
        UserRepository.clear
        UserRepository.all.must_be_empty
      end
    end
  end
end
