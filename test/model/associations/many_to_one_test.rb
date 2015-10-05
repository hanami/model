require 'test_helper'
require 'lotus/model/associations/many_to_one'

describe Lotus::Model::Associations::ManyToOne do
  let(:adapter) { Lotus::Model::Adapters::MemoryAdapter.new(MAPPER) }
  let(:association) { Lotus::Model::Associations::ManyToOne.new(options) }

  before { UserRepository.adapter = adapter }

  let(:user1) do
    user = User.new(name: 'Uku')
    UserRepository.create(user)
  end

  let(:user2) do
    user = User.new(name: 'Makis')
    UserRepository.create(user)
  end

  describe 'all options present' do
    let(:options) {
      {
        name:              :user,
        collection:        :users,
        foreign_key:       :user_id,
      }
    }

    it 'associates users for entities with user_id' do
      articles = [Article.new(user_id: user1.id), Article.new(user_id: user2.id)]
      association.repository = UserRepository
      association.associate_entities!(articles)

      articles[0].user.must_equal user1
      articles[1].user.must_equal user2
    end
  end

  describe 'inferring foreign key' do
    let(:options) {
      {
        name:              :user,
        collection:        :users,
      }
    }

    it 'associates users for entities with user_id' do
      articles = [Article.new(user_id: user1.id), Article.new(user_id: user2.id)]
      association.repository = UserRepository
      association.associate_entities!(articles)

      articles[0].user.must_equal user1
      articles[1].user.must_equal user2
    end
  end
end
