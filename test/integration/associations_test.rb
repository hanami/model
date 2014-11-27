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
      @book = Book.new(title: 'The healthy hacker')
      @user = User.new(name: 'Luca')
    end

    describe 'many to one' do
      describe 'fetching' do
        before do
          BookRepository.persist(@book)
          UserRepository.persist(@user)

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

        it "doesn't load associated entities by default" do
          review = ReviewRepository.find(@review.id)
          review.must_equal(@review)

          review.book.must_be_nil
          review.user.must_be_nil
        end

        it 'eagerly loads associated entities' do
          review = ReviewRepository.by_id(@review.id)
          review.must_equal(@review)

          review.book.must_equal(@book)
          review.user.must_equal(@user)
        end
      end
    end

    # describe 'writing' do
    #   describe 'when non persisted entity' do
    #     describe 'and non persisted associated entities' do
    #       before do
    #         @review = Review.new({
    #           book: @book,
    #           user: @user,
    #           title: 'Great advices',
    #           text:  'Blah blah',
    #           vote:  10
    #         })

    #         ReviewRepository.persist(@review)
    #       end

    #       it 'persists main entity' do
    #         @review.id.wont_be :nil?
    #       end

    #       it 'persists associated entities' do
    #         @book.id.wont_be :nil?
    #         @user.id.wont_be :nil?
    #       end
    #     end
    #   end
    # end
  end
end
