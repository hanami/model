RSpec.describe 'Associations (has_many :through)' do
  #### REPOS
  let(:books) { BookRepository.new }
  let(:categories) { CategoryRepository.new }
  let(:ontologies) { BookOntologyRepository.new }

  ### ENTITIES
  let(:book) { books.create(title: 'Ontology: Encyclopedia of Database Systems') }
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

    found = books.categories_for(book).to_a
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

  context '#delete' do
    it 'removes all association information' do
      books.add_category(book, category)
      categorized = books.find_with_categories(book.id)
      books.clear_categories(book)
      found = books.find_with_categories(book.id)

      expect(categorized.categories).to be_an Array
      expect(categorized.categories).to match_array([category])
      expect(found.categories).to be_empty
      expect(found).to eq(categorized)
    end

    it 'does not touch other books' do
      other_book = books.create(title: 'Do not meddle with')
      books.add_category(other_book, category)
      books.add_category(book, category)

      books.clear_categories(book)
      found = books.find_with_categories(book.id)
      other_found = books.find_with_categories(other_book.id)

      expect(found).to eq(book)
      expect(other_book).to eq(other_found)
      expect(other_found.categories).to eq([category])
      expect(found.categories).to be_empty
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

  context 'raises a Hanami::Model::Error wrapped exception on' do
    it '#add' do
      expect do
        categories.add_books(category, id: -2)
      end.to raise_error Hanami::Model::ForeignKeyConstraintViolationError
    end
  end

  context 'delegates scope manipulation to #scope' do
    let(:category_assoc) { books.categories_for(book) }

    it 'responds to #where' do
      expect(category_assoc).to respond_to :where
      expect { category_assoc.where(name: 'nonexistant') }.to_not raise_error
      expect(category_assoc.where(name: 'nonexistant').to_a.size).to eq(0)
    end

    it 'reponds to #limit' do
      expect(category_assoc).to respond_to :limit
      expect { category_assoc.limit(5) }.to_not raise_error
    end

    it 'responds to #order' do
      expect(category_assoc).to respond_to :order
      expect { category_assoc.order(:name) }.to_not raise_error
    end
  end
end
