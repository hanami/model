RSpec.describe 'Associations (has_many :through)' do
  it "returns nil if association wasn't preloaded" do
    repository = BookRepository.new
    book       = repository.create(title: 'L')
    found      = repository.find(book.id)

    expect(found.categories).to be(nil)
  end

  it 'preloads the associated record' do
    books = BookRepository.new
    book = books.create(title: 'Blaise Pascal')
  
    categories = CategoryRepository.new
    category = categories.create(name: 'biography')
  
    BooksCategoriesRepository.new.create(book_id: book.id, category_id: category.id)

    found = books.find_with_categories(book.id)

    expect(found).to eq(book)
    expect(found.categories).to eq([category])
  end

  it 'returns an array of Categories' do
    books = BookRepository.new
    book = books.create(title: 'Something Something')
  
    categories = CategoryRepository.new
    category = categories.create(name: 'another one')
  
    BooksCategoriesRepository.new.create(book_id: book.id, category_id: category.id)

    found = books.categories_for(book)
    expect(found).to eq([category])
  end

  it 'adds an object to the collection' do
    categories = CategoryRepository.new
    category = categories.create(name: 'some category')
    books = BookRepository.new
    book = books.create(title: 'Something Something')
    books.add_category(book, category.to_hash)

    found_book = books.find_with_categories(book.id)
    found_category = categories.find_with_books(category.id)

    expect(found_book).to eq(book)
    expect(found_book.categories).to eq([category])
    expect(found_category).to eq(category)
    expect(found_category.books).to eq([book])
  end

  # xit 'creates an object with a collection of associated objects' do
  #   repository = BookRepository.new
  #   book = repository.create_with_genres(name: , genres: [{name: }])

  #   expect(book).to be_an_instance_of(Author)
  #   expect(book.name).to eq()
  #   expect(boook.genres).to be_an_instance_of(Array)
  #   expect(boook.genres.first).to be_an_instance_of(Genre)
  #   expect(boook.genres.first.title).to eq()
  # end
end
