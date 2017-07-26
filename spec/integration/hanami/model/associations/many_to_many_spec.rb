RSpec.describe 'Associations (has_many :through)' do
  #### REPOS
  let(:books) { BookRepository.new }
  let(:categories) { CategoryRepository.new }
  let(:ontologies) { BookOntologyRepository.new }

  ### ENTITIES
  let(:book) { books.create(title: 'Ontology: Encyclopedia of Database Systems', on_sale: false) }
  let(:category) { categories.create(name: 'information science') }

  it "returns nil if association wasn't preloaded" do
    found = books.find(book.id)
    expect(found.categories).to be(nil)
  end

  it 'preloads the associated record' do
    ontologies.create(book_id: book.id, category_id: category.id)
    found = books.find_with_categories(book.id)

    expect(found).to eq(book)
    expect(found.categories).to eq([category])
  end

  it 'returns an array of Categories' do
    ontologies.create(book_id: book.id, category_id: category.id)

    found = books.categories_for(book)
    expect(found).to eq([category])
  end

  it 'returns the count of on sale associated books' do
    on_sale = books.create(title: 'The Sense of Style', on_sale: true)
    ontologies.create(book_id: on_sale.id, category_id: category.id)

    expect(categories.on_sales_books_count(category)).to eq(1)
  end


  context '#add' do
    it 'adds an object to the collection' do
      books.add_category(book, category)

      found_book = books.find_with_categories(book.id)
      found_category = categories.find_with_books(category.id)

      expect(found_book).to eq(book)
      expect(found_book.categories).to eq([category])
      expect(found_category).to eq(category)
      expect(found_category.books).to eq([book])
    end

    it 'associates a collection of records' do
      other_book = books.create(title: 'Ontological Engineering')
      categories.add_books(category, book, other_book)
      found = categories.find_with_books(category.id)

      expect(found.books).to match_array([book, other_book])
    end
  end

  context '#remove' do
    it 'removes the desired association' do
      to_remove = books.create(title: 'The Life of a Stoic')
      books.add_category(to_remove, category)

      categories.remove_book(category, to_remove.id)
      found = categories.find_with_books(category.id)

      expect(found.books).to_not include(to_remove)
    end
  end

  context 'collection methods' do
    it 'returns an array of books' do
      ontologies.create(book_id: book.id, category_id: category.id)

      actual = categories.books_for(category).to_a
      expect(actual).to eq([book])
    end

    it 'iterates through the categories' do
      ontologies.create(book_id: book.id, category_id: category.id)
      expected = categories.books_for(category)
      actual = []

      categories.books_for(category).each do |book|
        expect(book).to be_an_instance_of(Book)
        actual << book
      end

      expect(actual).to eq([book])
    end

    it 'iterates through the books and returns an array' do
      ontologies.create(book_id: book.id, category_id: category.id)

      actual = categories.books_for(category).map(&:id)
      expect(actual).to eq([book.id])
    end

    it 'returns the count of the associated books' do
      other_book = books.create(title: 'Practical Ontologies for Information Professionals')
      ontologies.create(book_id: book.id, category_id: category.id)
      ontologies.create(book_id: other_book.id, category_id: category.id)

      expect(categories.books_count(category)).to eq(2)
    end

  end
end
