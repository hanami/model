RSpec.describe 'Associations (has_many)' do
  let(:author_repository) { AuthorRepository.new }
  let(:book_repository) { BookRepository.new }

  it "returns nil if association wasn't preloaded" do
    author = author_repository.create(name: 'L')
    found = author_repository.find(author.id)

    expect(found.books).to be_nil
  end

  it 'preloads associated records' do
    author = author_repository.create(name: 'Umberto Eco')
    book = book_repository.create(author_id: author.id, title: 'Foucault Pendulum')

    found = author_repository.find_with_books(author.id)

    expect(found).to eq(author)
    expect(found.books).to eq([book])
  end

  it 'creates an object with a collection of associated objects' do
    author = author_repository.create_with_books(name: 'Henry Thoreau', books: [{ title: 'Walden' }])

    expect(author).to be_an_instance_of(Author)
    expect(author.name).to eq('Henry Thoreau')
    expect(author.books).to be_an_instance_of(Array)
    expect(author.books.first).to be_an_instance_of(Book)
    expect(author.books.first.title).to eq('Walden')
  end

  ##############################################################################
  # OPERATIONS                                                                 #
  ##############################################################################

  ##
  # ADD
  #
  it 'adds an object to the collection' do
    author = author_repository.create(name: 'Alexandre Dumas')
    book = author_repository.add_book(author, title: 'The Count of Monte Cristo')

    expect(book.id).to_not be_nil
    expect(book.title).to eq('The Count of Monte Cristo')
    expect(book.author_id).to eq(author.id)
  end

  ##
  # REMOVE
  #
  it 'removes an object from the collection'
  # it 'removes an object from the collection' do
  #   author_repository = AuthorRepository.new
  #   books = BookRepository.new

  #   # Book under test
  #   author = author_repository.create(name: 'Douglas Adams')
  #   book = book_repository.create(author_id: author.id, title: "The Hitchhiker's Guide to the Galaxy")

  #   # Different book
  #   a = author_repository.create(name: 'William Finnegan')
  #   b = book_repository.create(author_id: a.id, title: 'Barbarian Days: A Surfing Life')

  #   author_repository.remove_book(author, book.id)

  #   # Check the book under test has removed foreign key
  #   found_book = book_repository.find(book.id)
  #   expect(found_book).to_not be_nil
  #   expect(found_book.author_id).to be_nil

  #   found_author = author_repository.find_with_books(author.id)
  #   expect(found_author.book_repository.map(&:id)).to_not include(found_book.id)

  #   # Check that the other book was left untouched
  #   found_b = book_repository.find(b.id)
  #   expect(found_b.author_id).to eq(a.id)
  # end

  ##
  # TO_A
  #
  it 'returns an array of books' do
    author = author_repository.create(name: 'Nikolai Gogol')
    expected = book_repository.create(author_id: author.id, title: 'Dead Souls')
    expect(expected).to be_an_instance_of(Book)

    actual = author_repository.books_for(author).to_a
    expect(actual).to eq([expected])
  end

  ##
  # EACH
  #
  it 'iterates through the books' do
    author = author_repository.create(name: 'José Saramago')
    expected = book_repository.create(author_id: author.id, title: 'The Cave')

    actual = []
    author_repository.books_for(author).each do |book|
      expect(book).to be_an_instance_of(Book)
      actual << book
    end

    expect(actual).to eq([expected])
  end

  ##
  # MAP
  #
  it 'iterates through the books and returns an array' do
    author = author_repository.create(name: 'José Saramago')
    expected = book_repository.create(author_id: author.id, title: 'The Cave')
    expect(expected).to be_an_instance_of(Book)

    actual = author_repository.books_for(author).map { |book| book }
    expect(actual).to eq([expected])
  end

  ##
  # COUNT
  #
  it 'returns the count of the associated books' do
    author = author_repository.create(name: 'Fyodor Dostoevsky')
    book_repository.create(author_id: author.id, title: 'Crime and Punishment')
    book_repository.create(author_id: author.id, title: 'The Brothers Karamazov')

    expect(author_repository.books_count(author)).to eq(2)
  end

  it 'returns the count of on sale associated books' do
    author = author_repository.create(name: 'Steven Pinker')
    book_repository.create(author_id: author.id, title: 'The Sense of Style', on_sale: true)

    expect(author_repository.on_sales_books_count(author)).to eq(1)
  end

  ##
  # DELETE
  #
  it 'deletes all the books' do
    author = author_repository.create(name: 'Grazia Deledda')
    book = book_repository.create(author_id: author.id, title: 'Reeds In The Wind')

    author_repository.delete_books(author)

    expect(book_repository.find(book.id)).to be_nil
  end

  it 'deletes scoped books' do
    author = author_repository.create(name: 'Harper Lee')
    book = book_repository.create(author_id: author.id, title: 'To Kill A Mockingbird')
    on_sale = book_repository.create(author_id: author.id, title: 'Go Set A Watchman', on_sale: true)

    author_repository.delete_on_sales_books(author)

    expect(book_repository.find(book.id)).to eq(book)
    expect(book_repository.find(on_sale.id)).to be_nil
  end

  context 'raises a Hanami::Model::Error wrapped exception on' do
    it '#create' do
      expect do
        author_repository.create_with_books(name: 'Noam Chomsky')
      end.to raise_error Hanami::Model::Error
    end

    it '#add' do
      author = author_repository.create(name: 'Machado de Assis')
      expect do
        author_repository.add_book(author, title: 'O Aliennista', on_sale: nil)
      end.to raise_error Hanami::Model::NotNullConstraintViolationError
    end

    # This is already handled by Repository#delete if needed
    it '#delete'

    # skipped spec
    it '#remove'
  end
end
