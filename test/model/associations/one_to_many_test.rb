require 'test_helper'
require 'lotus/model/associations/one_to_many'

describe Lotus::Model::Associations::OneToMany do
  let(:adapter) { Lotus::Model::Adapters::MemoryAdapter.new(MAPPER) }

  let(:user) do
    User.new(name: 'Uku')
  end

  before do
    ArticleRepository.adapter = adapter
    UserRepository.adapter = adapter

    @persisted_user = UserRepository.create(user)
    @persisted_article1 = ArticleRepository.create(Article.new(user_id: @persisted_user.id))
    @persisted_article2 = ArticleRepository.create(Article.new(user_id: @persisted_user.id))
  end

  describe 'all options present' do
    let(:association) { Lotus::Model::Associations::OneToMany.new(options) }

    let(:options) {
      {
        name:              :articles,
        collection:        :articles,
        foreign_key:       :user_id,
      }
    }

    it 'associates users for entities with user_id' do
      association.repository = ArticleRepository
      association.associate_entities!([@persisted_user])

      @persisted_user.articles.must_equal [@persisted_article1, @persisted_article2]
    end
  end

  describe 'without foreign key' do
    let(:options) {
      {
        name:              :articles,
        collection:        :articles,
      }
    }

    it 'fail with KeyError' do
      proc { Lotus::Model::Associations::OneToMany.new(options) }.must_raise KeyError
    end
  end
end
