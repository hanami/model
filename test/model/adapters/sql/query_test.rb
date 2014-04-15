require 'test_helper'

describe Lotus::Model::Adapters::Sql::Query do
  before do
    @query = Lotus::Model::Adapters::Sql::Query.new(collection)
  end

  let(:collection) { [] }

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

  describe '#to_s' do
    let(:collection) { [1, 2, 3] }

    it 'delegates to the wrapped collection' do
      @query.to_s.must_equal collection.to_s
    end
  end

  describe '#empty?' do
    describe "when it's empty" do
      it 'returns true' do
        @query.must_be_empty
      end
    end

    describe "when it's filled with elements" do
      let(:collection) { [1, 2, 3] }

      it 'returns false' do
        @query.wont_be_empty
      end
    end
  end

  describe '#any?' do
    describe "when it's empty" do
      it 'returns false' do
        assert !@query.any?
      end
    end

    describe "when it's filled with elements" do
      let(:collection) { [1, 2, 3] }

      it 'returns true' do
        assert @query.any?
      end

      describe "when a block is passed" do
        describe "and it doesn't match elements" do
          it 'returns false' do
            assert !@query.any? {|e| e > 100 }
          end
        end

        describe "and it matches elements" do
          it 'returns true' do
            assert @query.any? {|e| e % 2 == 0 }
          end
        end
      end
    end
  end
end
