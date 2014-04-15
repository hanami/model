require 'test_helper'

describe Lotus::Model::Adapters::Sql::Query do
  before do
    collection = []
    @query     = Lotus::Model::Adapters::Sql::Query.new(collection)
  end

  describe '#negate!' do
    describe 'where' do
      before do
        @query.where(id: 1)
      end

      it 'negates with exclude' do
        @query.negate!
        operator, condition = *@query.conditions.first

        operator.must_equal :exclude
        condition.must_equal({id: 1})
      end
    end

    describe 'multipe where conditions' do
      before do
        @query.where(id: 1).and(name: 'L')
      end

      it 'negates with exclude' do
        @query.negate!
        operator, condition = *@query.conditions.last

        operator.must_equal :exclude
        condition.must_equal({name: 'L'})
      end
    end

    describe 'exclude' do
      before do
        @query.exclude(published: false)
      end

      it 'negates with where' do
        @query.negate!
        operator, condition = *@query.conditions.first

        operator.must_equal :where
        condition.must_equal({published: false})
      end
    end

    describe 'multiple exclude conditions' do
      before do
        @query.exclude(published: false).not(comments_count: 0)
      end

      it 'negates with where' do
        @query.negate!
        operator, condition = *@query.conditions.last

        operator.must_equal :where
        condition.must_equal({comments_count: 0})
      end
    end
  end
end
