RSpec.describe 'Associations (has_many :through)' do
  
  #### REPOS
  let(:books) { BookRepository.new }
  let(:categories) { CategoryRepository.new }
  let(:ontologies) { BookOntologyRepository.new }

  ### ENTITIES
  let(:book)  { books.create(title: 'Ontology: Encyclopedia of Database Systems') }
  let(:category) { categories.create(name: 'information science') }

  it "returns nil if association wasn't preloaded" do
    found      = books.find(book.id)
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

end
