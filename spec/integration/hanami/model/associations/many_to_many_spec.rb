RSpec.describe 'Associations (has_many :through)' do
  it "returns nil if association wasn't preloaded" do
    repository = BookRepository.new
    book       = repository.create(name: 'L')
    found      = repository.find(book.id)

    expect(found.author).to be(nil)
  end

  xit 'preloads the associated record' do
    repository = BookRepository.new
    found = repository.find_with_genres(book.id)

    expect(found).to eq(book)
    expect(found.author).to eq(author)
  end

  xit 'returns an array of Genres' do
    repository = BookRepository.new
    found = repository.genres_for(book)

    expect(found).to eq([genre])
  end

  xit 'creates an object with a collection of associated objects' do
    repository = BookRepository.new
    book = repository.create_with_genres(name: , genres: [{name: }])

    expect(book).to be_an_instance_of(Author)
    expect(book.name).to eq()
    expect(boook.genres).to be_an_instance_of(Array)
    expect(boook.genres.first).to be_an_instance_of(Genre)
    expect(boook.genres.first.title).to eq()
  end
end
