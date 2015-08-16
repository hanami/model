require 'test_helper'

describe Lotus::Repository do
  let(:user1) { User.new(name: 'L') }
  let(:user2) { User.new(name: 'MG') }
  let(:users) { [user1, user2] }

  let(:article1) { Article.new(user_id: user1.id, title: 'Introducing Lotus::Model', comments_count: '23') }
  let(:article2) { Article.new(user_id: user1.id, title: 'Thread safety',            comments_count: '42') }
  let(:article3) { Article.new(user_id: user2.id, title: 'Love Relationships',       comments_count: '4') }

  {
    memory:      [Lotus::Model::Adapters::MemoryAdapter,     nil,                           MAPPER],
    file_system: [Lotus::Model::Adapters::FileSystemAdapter, FILE_SYSTEM_CONNECTION_STRING, MAPPER],
    sql:         [Lotus::Model::Adapters::SqlAdapter,        SQLITE_CONNECTION_STRING,      MAPPER]
  }.each do |adapter_name, (adapter,uri,mapper)|
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
        describe 'when passed a non-persisted entity' do
          let(:unpersisted_user) { User.new(name: 'Don', age: '25') }

          it 'should return that entity' do
            persisted_user = UserRepository.persist(unpersisted_user)

            persisted_user.id.wont_be_nil
            persisted_user.name.must_equal(unpersisted_user.name)
            persisted_user.age.must_equal(unpersisted_user.age.to_i)
          end

          it 'returns a copy of the entity passed as argument' do
            persisted_user = UserRepository.persist(unpersisted_user)
            refute_same persisted_user, unpersisted_user
          end

          it 'does not assign an id on the entity passed as argument' do
            UserRepository.persist(unpersisted_user)
            unpersisted_user.id.must_be_nil
          end

          it 'should coerce attributes' do
            persisted_user = UserRepository.persist(unpersisted_user)
            persisted_user.age.must_equal(25)
          end

          it 'assigns and persist created_at attribute' do
            persisted_user = UserRepository.persist(unpersisted_user)
            persisted_user.created_at.wont_be_nil
          end

          it 'assigns and persist updated_at attribute' do
            persisted_user = UserRepository.persist(unpersisted_user)
            persisted_user.updated_at.must_equal persisted_user.created_at
          end
        end

        describe 'when passed a persisted entity' do
          before do
            @updated_at = user.updated_at
          end
          let(:user)           { UserRepository.create(User.new(name: 'Don')) }
          let(:persisted_user) { UserRepository.persist(user) }

          it 'should return that entity' do
            UserRepository.persist(persisted_user).must_equal(user)
          end

          it 'does not touch created_at' do
            UserRepository.persist(persisted_user)
            persisted_user.created_at.wont_be_nil
          end

          it 'touches updated_at' do
            updated_user = UserRepository.persist(user)
            assert updated_user.updated_at > @updated_at
          end
        end
      end

      describe '.create' do
        before do
          @users = [
            UserRepository.create(user1),
            UserRepository.create(user2)
          ]
        end

        it 'persist entities' do
          UserRepository.all.must_equal(@users)
        end

        it 'creates different kind of entities' do
          result = ArticleRepository.create(article1)
          ArticleRepository.all.must_equal([result])
        end

        it 'does nothing when already persisted' do
          id = user1.id

          UserRepository.create(user1)
          user1.id.must_equal id
        end

        it 'returns nil when trying to create an already persisted entity' do
          created_user = UserRepository.create(User.new(name: 'Pascal'))
          value = UserRepository.create(created_user)
          value.must_be_nil
        end

        describe 'when entity is not persisted' do
          let(:unpersisted_user) { User.new(name: 'My', age: '23') }

          it 'assigns and persists created_at attribute' do
            result = UserRepository.create(unpersisted_user)
            result.created_at.wont_be_nil
          end

          it 'assigns and persists updated_at attribute' do
            result = UserRepository.create(unpersisted_user)
            result.updated_at.must_equal result.created_at
          end
        end

        describe 'when entity is already persisted' do
          before do
            @persisted_user = UserRepository.create(User.new(name: 'My', age: '23'))
          end

          after do
            UserRepository.delete(@persisted_user)
          end

          it 'does not touch created_at' do
            UserRepository.create(@persisted_user)
            @persisted_user.created_at.wont_be_nil
          end
        end
      end

      describe '.update' do
        before do
          @user1 = UserRepository.create(user1)
          @updated_at = @user1.updated_at
        end

        it 'updates entities' do
          user = User.new(name: 'Luca')
          user.id = @user1.id

          updated_user = UserRepository.update(user)

          updated_user.name.must_equal('Luca')
        end

        it 'touches updated_at' do
          updated_user = UserRepository.update(@user1)

          assert updated_user.updated_at > @updated_at
        end

        it 'raises an error when not persisted' do
          -> { UserRepository.update(user2) }.must_raise(Lotus::Model::NonPersistedEntityError)
        end
      end

      describe '.delete' do
        before do
          @user = UserRepository.create(user)
          UserRepository.delete(@user)
        end

        let(:user) { User.new(name: 'D') }

        it 'delete entity' do
          UserRepository.all.wont_include(@user)
        end

        it 'raises error when the given entity is not persisted' do
          -> { UserRepository.delete(user2) }.must_raise(Lotus::Model::NonPersistedEntityError)
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
            @users = [
              UserRepository.create(user1),
              UserRepository.create(user2)
            ]
          end

          it 'returns all the entities' do
            UserRepository.all.must_equal(@users)
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
            TestPrimaryKey = Struct.new(:id) do
              def to_int
                id
              end
            end

            @user1 = UserRepository.create(user1)
            @user2 = UserRepository.create(user2)

            @article1 = ArticleRepository.create(article1)
          end

          after do
            Object.send(:remove_const, :TestPrimaryKey)
          end

          it 'returns the entity associated with the given id' do
            UserRepository.find(@user1.id).must_equal(@user1)
          end

          it 'accepts a string as argument' do
            UserRepository.find(@user2.id.to_s).must_equal(@user2)
          end

          it 'accepts an object that can be coerced to integer' do
            id = TestPrimaryKey.new(@user2.id)
            UserRepository.find(id).must_equal(@user2)
          end

          it 'coerces attributes as indicated by the mapper' do
            result = ArticleRepository.find(@article1.id)
            result.comments_count.must_be_kind_of(Integer)
          end

          it "doesn't assign a value to unmapped attributes" do
            ArticleRepository.find(@article1.id).unmapped_attribute.must_be_nil
          end

          it "returns nil when the given id isn't associated with any entity" do
            UserRepository.find(1_000_000).must_be_nil
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
            @user1 = UserRepository.create(user1)
            UserRepository.create(user2)
          end

          it 'returns first record' do
            UserRepository.first.must_equal(@user1)
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
            @user2 = UserRepository.create(user2)
          end

          it 'returns last record' do
            UserRepository.last.must_equal(@user2)
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

      describe 'querying' do
        before do
          @user1    = UserRepository.create(user1)
          article1.user_id = article2.user_id = @user1.id

          @article1 = ArticleRepository.create(article1)
          @article2 = ArticleRepository.create(article2)
          ArticleRepository.create(article3)
        end

        it 'defines custom finders' do
          actual = ArticleRepository.by_user(@user1)
          actual.all.must_equal [@article1, @article2]
        end

        if adapter_name == :sql
          it 'combines queries' do
            actual = ArticleRepository.rank_by_user(@user1)
            actual.all.must_equal [@article2, @article1]
          end

          it 'negates a query' do
            actual = ArticleRepository.not_by_user(@user1)
            actual.all.must_equal []
          end
        end
      end

      describe 'dirty tracking' do
        before do
          @article = ArticleRepository.create(article1)
        end

        it "hasn't dirty state after creation" do
          @article.changed?.must_equal false
        end

        it "hasn't dirty state after finding" do
          found = ArticleRepository.find(@article.id)
          found.changed?.must_equal false
        end

        it "hasn't dirty state after update" do
          @article.title = 'Dirty tracking'
          @article = ArticleRepository.update(@article)

          @article.changed?.must_equal false
        end
      end

      describe 'missing timestamps attribute' do
        describe '.persist' do
          before do
            @article = ArticleRepository.persist(Article.new(title: 'Lotus', comments_count: '4'))
            @article.instance_eval do
              def created_at
                @created_at
              end

              def updated_at
                @updated_at
              end
            end
          end

          after do
            ArticleRepository.delete(@article)
          end

          describe 'when entity does not have created_at accessor' do
            it 'does not touch created_at' do
              @article.created_at.must_be_nil
            end
          end

          describe 'when entity does not have updated_at accessor' do
            it 'does not touch updated_at' do
              @article.updated_at.must_be_nil
            end
          end
        end
      end
    end
  end

  describe "with sql adapter" do
    before do
      UserRepository.adapter    = Lotus::Model::Adapters::SqlAdapter.new(MAPPER, SQLITE_CONNECTION_STRING)
      ArticleRepository.adapter = Lotus::Model::Adapters::SqlAdapter.new(MAPPER, SQLITE_CONNECTION_STRING)

      UserRepository.collection    = :users
      ArticleRepository.collection = :articles

      UserRepository.clear
      ArticleRepository.clear

      ArticleRepository.create(article1)
    end

    describe '.transaction' do
      it 'if an exception is raised the size of articles is equal to 1' do
        ArticleRepository.all.size.must_equal 1
        exception = -> { ArticleRepository.transaction do
          ArticleRepository.create(article2)
          raise Exception
        end }
        exception.must_raise Exception
        ArticleRepository.all.size.must_equal 1
      end

      it "if an exception isn't raised the size of articles is equal to 2" do
        ArticleRepository.all.size.must_equal 1
        ArticleRepository.transaction do
          ArticleRepository.create(article2)
        end
        ArticleRepository.all.size.must_equal 2
      end

      describe 'using options' do
        it 'rollback: :always option' do
          ArticleRepository.all.size.must_equal 1
          ArticleRepository.transaction(rollback: :always) do
            ArticleRepository.create(article2)
          end
          ArticleRepository.all.size.must_equal 1
        end

        it 'rollback: :reraise option' do
          ArticleRepository.all.size.must_equal 1
          -> { ArticleRepository.transaction(rollback: :reraise) do
            ArticleRepository.create(article2)
            raise Exception
          end }.must_raise Exception
          ArticleRepository.all.size.must_equal 1
        end
      end
    end

    describe '.execute' do
      it 'is a private method' do
        -> { ArticleRepository.execute("select * from articles") }.must_raise NoMethodError
      end

      it 'returns the ResultSet from the executes sql' do
        result = ArticleRepository.aggregate
        result.class.name.must_equal "SQLite3::ResultSet"
        result.count.must_equal 1
      end
    end

  end

  describe "with memory adapter" do
    before do
      UserRepository.adapter    = Lotus::Model::Adapters::MemoryAdapter.new(MAPPER, nil)
      ArticleRepository.adapter = Lotus::Model::Adapters::MemoryAdapter.new(MAPPER, nil)

      UserRepository.collection    = :users
      ArticleRepository.collection = :articles

      UserRepository.clear
      ArticleRepository.clear
    end

    describe '.transaction' do
      it "an exception is raised because of memory adapter doesn't support transactions" do
        -> { ArticleRepository.transaction do
          raise "boom"
        end }.must_raise RuntimeError
      end
    end

    describe '.execute' do
      it 'is a private method' do
        -> { ArticleRepository.execute("select * from articles") }.must_raise NoMethodError
      end

      it "raises an exception because memory adapter doesn't support execute" do
        -> { ArticleRepository.aggregate }.must_raise NotImplementedError
      end
    end
  end
end
