require 'test_helper'

describe 'Associations (has_many)' do
  it "returns nil if association wasn't preloaded" do
    repository = AuthorRepository.new
    author = repository.create(name: 'L')
    found  = repository.find(author.id)

    found.books.must_equal nil
  end

  it 'preloads associated records' do
    repository = AuthorRepository.new

    author  = repository.create(name: 'Umberto Eco')
    book    = BookRepository.new.create(author_id: author.id, title: 'Foucault Pendulum')

    found = repository.find_with_books(author.id)

    found.must_equal author
    found.books.must_equal [book]
  end

  it 'creates an object with a collection of associated objects'
  # it 'creates an object with a collection of associated objects' do
  #   repository = AuthorRepository.new
  #   author = repository.create_with_books(name: 'Henry Thoreau', books: [{ title: 'Walden' }])

  #   author.name.must_equal 'Fowler'
  # end

  ##############################################################################
  # OPERATIONS                                                                 #
  ##############################################################################

  ##
  # ADD
  #
  it 'adds an object to the collection' do
    repository = AuthorRepository.new

    author  = repository.create(name: 'Alexandre Dumas')
    book    = repository.add_book(author, title: 'The Count of Monte Cristo')

    book.id.wont_be_nil
    book.title.must_equal 'The Count of Monte Cristo'
    book.author_id.must_equal author.id
  end

  ##
  # REMOVE
  #
  it 'removes an object from the collection'
  # it 'removes an object from the collection' do
  #   repository = AuthorRepository.new
  #   books      = BookRepository.new

  #   # Book under test
  #   author = repository.create(name: 'Douglas Adams')
  #   book   = books.create(author_id: author.id, title: "The Hitchhiker's Guide to the Galaxy")

  #   # Different book
  #   a = repository.create(name: 'William Finnegan')
  #   b = books.create(author_id: a.id, title: 'Barbarian Days: A Surfing Life')

  #   repository.remove_book(author, book.id)

  #   # Check the book under test has removed foreign key
  #   found_book = books.find(book.id)
  #   found_book.wont_be_nil
  #   found_book.author_id.must_be_nil

  #   found_author = repository.find_with_books(author.id)
  #   found_author.books.map(&:id).wont_include(found_book.id)

  #   # Check that the other book was left untouched
  #   found_b = books.find(b.id)
  #   found_b.author_id.must_equal(a.id)
  # end

  ##
  # TO_A
  #
  it 'returns an array of books' do
    repository = AuthorRepository.new
    books      = BookRepository.new

    author   = repository.create(name: 'Nikolai Gogol')
    expected = books.create(author_id: author.id, title: 'Dead Souls')
    expected.must_be_instance_of(Book)

    actual = repository.books_for(author).to_a
    actual.must_equal [expected]
  end

  ##
  # EACH
  #
  it 'iterates through the books' do
    repository = AuthorRepository.new
    books      = BookRepository.new

    author   = repository.create(name: 'José Saramago')
    expected = books.create(author_id: author.id, title: 'The Cave')

    actual = []
    repository.books_for(author).each do |book|
      book.must_be_instance_of(Book)
      actual << book
    end

    actual.must_equal [expected]
  end

  ##
  # MAP
  #
  it 'iterates through the books and returns an array' do
    repository = AuthorRepository.new
    books      = BookRepository.new

    author   = repository.create(name: 'José Saramago')
    expected = books.create(author_id: author.id, title: 'The Cave')
    expected.must_be_instance_of(Book)

    actual = repository.books_for(author).map { |book| book }
    actual.must_equal [expected]
  end

  ##
  # COUNT
  #
  it 'returns the count of the associated books' do
    repository = AuthorRepository.new
    books      = BookRepository.new

    author = repository.create(name: 'Fyodor Dostoevsky')
    books.create(author_id: author.id, title: 'Crime and Punishment')
    books.create(author_id: author.id, title: 'The Brothers Karamazov')

    repository.books_count(author).must_equal(2)
  end

  it 'returns the count of on sale associated books' do
    repository = AuthorRepository.new
    books      = BookRepository.new

    author = repository.create(name: 'Steven Pinker')
    books.create(author_id: author.id, title: 'The Sense of Style', on_sale: true)

    repository.on_sales_books_count(author).must_equal(1)
  end

  ##
  # DELETE
  #
  it 'deletes all the books' do
    repository = AuthorRepository.new
    books      = BookRepository.new

    author = repository.create(name: 'Grazia Deledda')
    book   = books.create(author_id: author.id, title: 'Reeds In The Wind')

    repository.delete_books(author)

    books.find(book.id).must_be_nil
  end

  it 'deletes scoped books' do
    repository = AuthorRepository.new
    books      = BookRepository.new

    author  = repository.create(name: 'Harper Lee')
    book    = books.create(author_id: author.id, title: 'To Kill A Mockingbird')
    on_sale = books.create(author_id: author.id, title: 'Go Set A Watchman', on_sale: true)

    repository.delete_on_sales_books(author)

    books.find(book.id).must_equal(book)
    books.find(on_sale.id).must_be_nil
  end
end
