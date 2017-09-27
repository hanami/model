RSpec.describe 'Associations (has_many)' do
  let(:authors) { AuthorRepository.new }
  let(:books) { BookRepository.new }

  it "returns nil if association wasn't preloaded" do
    author = authors.create(name: 'L')
    found = authors.find(author.id)

    expect(found.books).to be_nil
  end

  it 'preloads associated records' do
    author = authors.create(name: 'Umberto Eco')
    book = books.create(author_id: author.id, title: 'Foucault Pendulum')

    found = authors.find_with_books(author.id)

    expect(found).to eq(author)
    expect(found.books).to eq([book])
  end

  it 'creates an object with a collection of associated objects' do
    author = authors.create_with_books(name: 'Henry Thoreau', books: [{ title: 'Walden' }])

    expect(author).to be_an_instance_of(Author)
    expect(author.name).to eq('Henry Thoreau')
    expect(author.books).to be_an_instance_of(Array)
    expect(author.books.first).to be_an_instance_of(Book)
    expect(author.books.first.title).to eq('Walden')
  end

  it 'creates associated records when it receives a collection of serializable data' do
    author = authors.create_with_books(name: 'Sandi Metz', books: [BaseParams.new(title: 'Practical Object-Oriented Design in Ruby')])

    expect(author).to be_an_instance_of(Author)
    expect(author.name).to eq('Sandi Metz')
    expect(author.books).to be_an_instance_of(Array)
    expect(author.books.first).to be_an_instance_of(Book)
    expect(author.books.first.title).to eq('Practical Object-Oriented Design in Ruby')
  end

  ##############################################################################
  # OPERATIONS                                                                 #
  ##############################################################################

  ##
  # ADD
  #
  it 'adds an object to the collection' do
    author = authors.create(name: 'Alexandre Dumas')
    book = authors.add_book(author, title: 'The Count of Monte Cristo')

    expect(book.id).to_not be_nil
    expect(book.title).to eq('The Count of Monte Cristo')
    expect(book.author_id).to eq(author.id)
  end

  it 'adds an object to the collection with serializable data' do
    author = authors.create(name: 'David Foster Wallace')
    book = authors.add_book(author, BaseParams.new(title: 'Infinite Jest'))

    expect(book.id).to_not be_nil
    expect(book.title).to eq('Infinite Jest')
    expect(book.author_id).to eq(author.id)
  end

  ##
  # REMOVE
  #
  it 'removes an object from the collection' do
    authors = AuthorRepository.new
    books = BookRepository.new

    # Book under test
    author = authors.create(name: 'Douglas Adams')
    book = books.create(author_id: author.id, title: "The Hitchhiker's Guide to the Galaxy")

    # Different book
    a = authors.create(name: 'William Finnegan')
    b = books.create(author_id: a.id, title: 'Barbarian Days: A Surfing Life')

    authors.remove_book(author, book.id)

    # Check the book under test has removed foreign key
    found_book = books.find(book.id)
    expect(found_book).to_not be_nil
    expect(found_book.author_id).to be_nil

    found_author = authors.find_with_books(author.id)
    expect(found_author.books.map(&:id)).to_not include(found_book.id)

    # Check that the other book was left untouched
    found_b = books.find(b.id)
    expect(found_b.author_id).to eq(a.id)
  end

  ##
  # TO_A
  #
  it 'returns an array of books' do
    author = authors.create(name: 'Nikolai Gogol')
    expected = books.create(author_id: author.id, title: 'Dead Souls')
    expect(expected).to be_an_instance_of(Book)

    actual = authors.books_for(author).to_a
    expect(actual).to eq([expected])
  end

  ##
  # EACH
  #
  it 'iterates through the books' do
    author = authors.create(name: 'José Saramago')
    expected = books.create(author_id: author.id, title: 'The Cave')

    actual = []
    authors.books_for(author).each do |book|
      expect(book).to be_an_instance_of(Book)
      actual << book
    end

    expect(actual).to eq([expected])
  end

  ##
  # MAP
  #
  it 'iterates through the books and returns an array' do
    author = authors.create(name: 'José Saramago')
    expected = books.create(author_id: author.id, title: 'The Cave')
    expect(expected).to be_an_instance_of(Book)

    actual = authors.books_for(author).map { |book| book }
    expect(actual).to eq([expected])
  end

  ##
  # COUNT
  #
  it 'returns the count of the associated books' do
    author = authors.create(name: 'Fyodor Dostoevsky')
    books.create(author_id: author.id, title: 'Crime and Punishment')
    books.create(author_id: author.id, title: 'The Brothers Karamazov')

    expect(authors.books_count(author)).to eq(2)
  end

  it 'returns the count of on sale associated books' do
    author = authors.create(name: 'Steven Pinker')
    books.create(author_id: author.id, title: 'The Sense of Style', on_sale: true)

    expect(authors.on_sales_books_count(author)).to eq(1)
  end

  ##
  # DELETE
  #
  it 'deletes all the books' do
    author = authors.create(name: 'Grazia Deledda')
    book = books.create(author_id: author.id, title: 'Reeds In The Wind')

    authors.delete_books(author)

    expect(books.find(book.id)).to be_nil
  end

  it 'deletes scoped books' do
    author = authors.create(name: 'Harper Lee')
    book = books.create(author_id: author.id, title: 'To Kill A Mockingbird')
    on_sale = books.create(author_id: author.id, title: 'Go Set A Watchman', on_sale: true)

    authors.delete_on_sales_books(author)

    expect(books.find(book.id)).to eq(book)
    expect(books.find(on_sale.id)).to be_nil
  end

  context 'raises a Hanami::Model::Error wrapped exception on' do
    it '#create' do
      expect do
        authors.create_with_books(name: 'Noam Chomsky')
      end.to raise_error Hanami::Model::Error
    end

    it '#add' do
      author = authors.create(name: 'Machado de Assis')
      expect do
        authors.add_book(author, title: 'O Alienista', on_sale: nil)
      end.to raise_error Hanami::Model::NotNullConstraintViolationError
    end

    # skipped spec
    it '#remove'
  end

  context 'delegates scope manipulation to #scope' do
    let(:author) { authors.create_with_books(name: 'Luis de Camões', books: [{ title: 'Os Lusíadas' }]) }
    let(:book_assoc) { authors.books_for(id: author.id) }

    it 'responds to #where' do
      expect(book_assoc).to respond_to :where
      expect { book_assoc.where(title: 'Os Lusíadas') }.to_not raise_error
      expect(book_assoc.where(title: 'Os Lusíadas').to_a.size).to eq(1)
    end

    it 'reponds to #limit' do
      expect(book_assoc).to respond_to :limit
      expect { book_assoc.limit(5) }.to_not raise_error
    end

    it 'responds to #order' do
      expect(book_assoc).to respond_to :order
      expect { book_assoc.order(:title) }.to_not raise_error
    end
  end
end
