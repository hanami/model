require 'test_helper'

describe Lotus::Repository do
  before do
    adapter, uri, mapper = Lotus::Model::Adapters::SqlAdapter, SQLITE_CONNECTION_STRING, MAPPER
    ArticleRepository.adapter = adapter.new(mapper, uri)
  end

  describe 'manipulation of timestamps' do
    let(:article) { Article.new(title: 'New article with timestamp') }
    let(:persisted_article) { ArticleRepository.create(article) }

    describe "create procedure" do
      it "touches .created_at attribute" do
        article.created_at.must_be_nil
        persisted_article.created_at.wont_be_nil
      end
      it "touches .udpated_at attribute" do
        article.updated_at.must_be_nil
        persisted_article.updated_at.wont_be_nil
      end
    end

    describe "update procedure" do
      it 'changes .updated_at attribute' do
        old_updated_at = persisted_article.updated_at
        Time.stub :now, Time.now + 10 do
          article.title = 'Very new article'
          updated_article = ArticleRepository.persist(article)
          updated_article.updated_at.to_time.must_be :>, old_updated_at.to_time
        end
      end
    end
  end
end
