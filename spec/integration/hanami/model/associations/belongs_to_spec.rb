# frozen_string_literal: true

RSpec.describe "Associations (belongs_to)" do
  it "returns nil if association wasn't preloaded" do
    repository = BookRepository.new(configuration: configuration)
    book       = repository.create(name: "L")
    found      = repository.find(book.id)

    expect(found.author).to be(nil)
  end

  it "preloads the associated record" do
    repository = BookRepository.new(configuration: configuration)
    author = AuthorRepository.new(configuration: configuration).create(name: "Michel Foucault")
    book   = repository.create(author_id: author.id, title: "Surveiller et punir")
    found = repository.find_with_author(book.id)

    expect(found).to eq(book)
    expect(found.author).to eq(author)
  end

  it "returns an author" do
    repository = BookRepository.new(configuration: configuration)
    author = AuthorRepository.new(configuration: configuration).create(name: "Maurice Leblanc")
    book   = repository.create(author_id: author.id, title: "L'Aguille Creuse")
    found = repository.author_for(book)

    expect(found).to eq(author)
  end

  it "returns nil if there's no associated record" do
    repository = BookRepository.new(configuration: configuration)
    book = repository.create(title: "The no author book")

    expect { repository.find_with_author(book.id) }.to_not raise_error
  end
end
