RSpec.describe "Hanami::Model::VERSION" do
  it 'exposes version' do
    expect(Hanami::Model::VERSION).to eq('1.0.2')
  end
end
