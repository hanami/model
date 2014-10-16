require 'test_helper'

describe 'Configuration DSL' do
  before do
    Lotus::Model.configure do
      adapter :memory, 'memory://localhost', default: true
      adapter :sql, SQLITE_CONNECTION_STRING

      mapping do
        adapter :sql do
          collection :users do
            entity     User
            repository UserRepository

            attribute :id,   Integer
            attribute :name, String
          end
        end

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

    Lotus::Model.load!
  end

  after do
    Lotus::Model.unload!
  end

  describe 'when adapter name is explicitly provided' do
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

    it 'uses given adapter' do
      UserRepository.instance_variable_get(:@adapter).must_be_kind_of Lotus::Model::Adapters::SqlAdapter
    end
  end

  describe 'when adapter name is not explicitly provided' do
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

    it 'uses default adapter' do
      ArticleRepository.instance_variable_get(:@adapter).must_be_kind_of Lotus::Model::Adapters::MemoryAdapter
    end
  end
end
