require 'test_helper'

describe 'Configuration DSL' do
  before do
    Lotus::Model.configure do
      adapter :sqlite3, :sql, SQLITE_CONNECTION_STRING, default: true
      adapter :cache, :memory

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

        adapter :sqlite3 do
          collection :articles do
            entity Article

            attribute :id,             Integer, as: :_id
            attribute :user_id,        Integer
            attribute :title,          String,  as: 's_title'
            attribute :comments_count, Integer

            identity :_id
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
      UserRepository.clear
      CustomUserRepository.clear
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

  describe 'when creating new article' do
    before do
      @article = Article.new(title: 'The Zen')
      ArticleRepository.clear
    end

    it 'add the entity to repositories' do
      @article_counter = ArticleRepository.all.size

      ArticleRepository.create(@article)
      ArticleRepository.instance_variable_get(:@adapter).must_be_kind_of Lotus::Model::Adapters::SqlAdapter

      articles = ArticleRepository.all
      articles.size.must_equal(@article_counter + 1)
      articles.first.must_equal(@article)
    end
  end
end
