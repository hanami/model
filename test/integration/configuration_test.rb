require 'test_helper'

describe 'Configuration DSL' do
  before do
    Lotus::Model.configure do
      adapter :memory, 'memory://localhost', default: true
      adapter :sql, SQLITE_CONNECTION_STRING

      mapping do
        collection :users do
          entity     User
          repository UserRepository

          attribute :id,   Integer
          attribute :name, String
        end

        adapter :sql do
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
    end

    it 'add the entity to repositories' do
      @user_counter = UserRepository.all.size

      UserRepository.create(@user)

      users = UserRepository.all
      users.size.must_equal(@user_counter + 1)
      users.first.must_equal(@user)
    end

    it 'uses memory adapter' do
      UserRepository.instance_variable_get(:@adapter).must_be_kind_of Lotus::Model::Adapters::MemoryAdapter
    end
  end

  describe 'when creating new article' do
    before do
      @article = Article.new(title: 'The Zen Art of Lotus')
    end

    it 'add the entity to repositories' do
      @article_counter = ArticleRepository.all.size

      ArticleRepository.create(@article)

      articles = ArticleRepository.all
      articles.size.must_equal(@article_counter + 1)
      articles.first.must_equal(@article)
    end

    it 'uses SQL adapter' do
      ArticleRepository.instance_variable_get(:@adapter).must_be_kind_of Lotus::Model::Adapters::SqlAdapter
    end
  end
end
