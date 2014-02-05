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
    before do
      UserRepository.persist(user1)
      UserRepository.persist(user2)
    end

    it 'persists records' do
      UserRepository.all.must_equal(users)
    end

    it 'persists different kind of records' do
      ArticleRepository.persist(article)
      ArticleRepository.all.must_equal([article])
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
        UserRepository.persist(users)
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
        UserRepository.persist(users)
      end

      it 'returns first record' do
        UserRepository.find(user1.send(:id)).must_equal(user1)
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
        UserRepository.persist(users)
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
        UserRepository.persist(users)
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
        UserRepository.persist(users)
      end

      it 'removes all the records' do
        UserRepository.clear
        UserRepository.all.must_be_empty
      end
    end
  end
end
