RSpec.describe "Hanami::Model::Sql::Types::Schema::String" do
  let(:described_class) { Hanami::Model::Sql::Types::Schema::String }

  it 'returns nil for nil' do
    input = nil
    expect(described_class[input]).to eq(input)
  end

  it 'coerces string' do
    input = 'foo'
    expect(described_class[input]).to eq(input.to_s)
  end

  it 'coerces symbol' do
    input = :foo
    expect(described_class[input]).to eq(input.to_s)
  end

  it 'coerces integer' do
    input = 23
    expect(described_class[input]).to eq(input.to_s)
  end

  it 'coerces float' do
    input = 3.14
    expect(described_class[input]).to eq(input.to_s)
  end

  it 'coerces bigdecimal' do
    input = BigDecimal(3.14, 10)
    expect(described_class[input]).to eq(input.to_s)
  end

  it 'coerces date' do
    input = Date.today
    expect(described_class[input]).to eq(input.to_s)
  end

  it 'coerces datetime' do
    input = DateTime.new
    expect(described_class[input]).to eq(input.to_s)
  end

  it 'coerces time' do
    input = Time.now
    expect(described_class[input]).to eq(input.to_s)
  end

  it 'coerces array' do
    input = []
    expect(described_class[input]).to eq(input.to_s)
  end

  it 'coerces hash' do
    input = {}
    expect(described_class[input]).to eq(input.to_s)
  end
end
