require 'test_helper'

describe 'Associations' do
  before do
    Lotus::Model.configure do
      adapter type: :sql, uri: SQLITE_CONNECTION_STRING

      mapping do
        collection :users do
          entity     User
          repository UserRepository

          attribute :id,   Integer
          attribute :name, String
        end

        collection :books do
          entity     Book
          repository BookRepository

          attribute :id,    Integer
          attribute :title, String
        end

        collection :reviews do
          entity     Review
          repository ReviewRepository

          attribute   :id,      Integer
          many_to_one :book,    Book
          many_to_one :user,    User
          attribute   :title,   String
          attribute   :text,    String
          attribute   :vote,    Integer
        end
      end
    end

    Lotus::Model.load!
  end

  after do
    Lotus::Model.unload!
  end

  describe 'associations' do
    before do
      BookRepository.persist(
        @book = Book.new(title: 'The healthy hacker')
      )

      UserRepository.persist(
        @user = User.new(name: 'Luca')
      )
    end

    describe 'many to one' do
      before do
        id = DB[:reviews].insert({
          book_id: @book.id,
          user_id: @user.id,
          title:   'Great advices',
          text:    'Blah blah',
          vote:    10
        })

        @review = Review.new({
          id:   id,
          book: @book,
          user: @user,
          title: 'Great advices',
          text:  'Blah blah',
          vote:  10
        })
      end

      it 'loads associated entity' do
        review = ReviewRepository.by_id(@review.id)
        review.must_equal(@review)

        review.book.must_equal(@book)
      end
    end
  end
end
