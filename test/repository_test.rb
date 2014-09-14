require 'test_helper'

describe Lotus::Repository do
  let(:user1) { User.new(name: 'L') }
  let(:user2) { User.new(name: 'MG') }
  let(:users) { [user1, user2] }

  let(:article1) { Article.new(user_id: user1.id, title: 'Introducing Lotus::Model', comments_count: '23') }
  let(:article2) { Article.new(user_id: user1.id, title: 'Thread safety',            comments_count: '42') }
  let(:article3) { Article.new(user_id: user2.id, title: 'Love Relationships',       comments_count: '4') }

  { memory: [Lotus::Model::Adapters::MemoryAdapter, nil, MAPPER],
    sql:    [Lotus::Model::Adapters::SqlAdapter, SQLITE_CONNECTION_STRING, MAPPER] }.each do |adapter_name, (adapter,uri,mapper)|
    describe "with #{ adapter_name } adapter" do
      before do
        UserRepository.adapter    = adapter.new(mapper, uri)
        ArticleRepository.adapter = adapter.new(mapper, uri)

        UserRepository.collection    = :users
        ArticleRepository.collection = :articles

        UserRepository.clear
        ArticleRepository.clear
      end

      describe '.collection' do
        it 'returns the collection name' do
          UserRepository.collection.must_equal    :users
          ArticleRepository.collection.must_equal :articles
        end
      end

      describe '.persist' do
        describe 'when non persisted' do
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

        it 'persist entities' do
          UserRepository.all.must_equal(users)
        end

        it 'creates different kind of entities' do
          ArticleRepository.create(article1)
          ArticleRepository.all.must_equal([article1])
        end

        it 'does nothing when already persisted' do
          id = user1.id

          UserRepository.create(user1)
          user1.id.must_equal id
        end
      end

      describe '.update' do
        before do
          UserRepository.create(user1)
        end

        let(:id) { user1.id }

        it 'updates entities' do
          user = User.new(name: 'Luca')
          user.id = id

          UserRepository.update(user)

          u = UserRepository.find(id)
          u.name.must_equal('Luca')
        end

        it 'raises an error when not persisted' do
          -> { UserRepository.update(user2) }.must_raise(Lotus::Model::NonPersistedEntityError)
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

        it 'raises error when the given entity is not persisted' do
          -> { UserRepository.delete(user2) }.must_raise(Lotus::Model::NonPersistedEntityError)
        end
      end

      describe '.all' do
        it 'returns an empty collection' do
          UserRepository.all.must_be_empty
        end
      end

      describe '.find' do
        it 'raises error' do
          -> { UserRepository.find(1) }.must_raise(Lotus::Model::EntityNotFound)
        end
      end

      describe '.first' do
        it 'returns nil' do
          UserRepository.first.must_be_nil
        end
      end

      describe '.last' do
        it 'returns nil' do
          UserRepository.last.must_be_nil
        end
      end

      describe '.clear' do
        it 'removes all the records' do
          UserRepository.clear
          UserRepository.all.must_be_empty
        end
      end

      describe 'querying' do
        before do
          UserRepository.create(user1)
          ArticleRepository.create(article1)
          ArticleRepository.create(article2)
          ArticleRepository.create(article3)
        end

        it 'defines custom finders' do
          actual = ArticleRepository.by_user(user1)
          actual.all.must_equal [article1, article2]
        end

        if adapter_name == :sql
          it 'combines queries' do
            actual = ArticleRepository.rank_by_user(user1)
            actual.all.must_equal [article2, article1]
          end

          it 'negates a query' do
            actual = ArticleRepository.not_by_user(user1)
            actual.all.must_equal []
          end
        end
      end
    end
  end

  describe "with no adapter" do
    before do
      UserRepository.adapter    = nil
      ArticleRepository.adapter = nil

      UserRepository.collection    = :users
      ArticleRepository.collection = :articles
    end
    let(:user) { User.new(name: 'S') }

    describe '.collection' do
      it 'returns the collection name' do
        UserRepository.collection.must_equal    :users
        ArticleRepository.collection.must_equal :articles
      end
    end

    {
     '.persist' => -> { UserRepository.persist(User.new) },
     '.create' => -> { UserRepository.create(User.new) },
     '.update' => -> { UserRepository.update(User.new) },
     '.delete' => -> { UserRepository.delete(User.new) },
     '.all' => -> { UserRepository.all },
     '.find' => -> { UserRepository.find(1) },
     '.first' => -> { UserRepository.first },
     '.last' => -> { UserRepository.last },
     '.clear' => -> { UserRepository.clear },
     'defining custom finders' => -> { ArticleRepository.by_user(User.new) },
     'combining queries' => -> { ArticleRepository.rank_by_user(User.new) },
     'negating a query' => -> { ArticleRepository.not_by_user(User.new) },
    }.each do |description, code|
      describe description do
        it 'raises an error' do
          code.must_raise(Lotus::Repository::NoAdapterError)
        end
      end
    end
  end
end
