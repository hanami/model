# frozen_string_literal: true

RSpec.describe "Customized commands" do
  subject(:authors) { AuthorRepository.new }

  let(:data) do
    [{name: "Arthur C. Clarke"}, {name: "Phillip K. Dick"}]
  end

  context "the mapper" do
    it "is enabled by default" do
      result = authors.create_many(data)
      expect(result).to be_an Array
      expect(result).to all(be_an(Author))
    end

    it "can be explictly turned off" do
      result = authors.create_many(data, opts: {mapper: nil})
      expect(result).to all(be_an(ROM::Struct))
    end
  end

  context "timestamps" do
    it "are enabled by default" do
      result = authors.create_many(data)
      expect(result.first.created_at).to be_within(2).of(Time.now.utc)
    end
  end
end
