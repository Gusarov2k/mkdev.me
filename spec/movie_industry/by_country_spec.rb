RSpec.describe MovieIndustry::ByCountry do
  let(:testing_obj) { described_class.new(movies) }
  let(:movies)      { MovieIndustry::MovieCollection.new('./spec/fixtures/movies.txt') }
  let(:countrys) do
    {
      usa: 'USA',
      italy: 'Italy',
      france: 'France',
      brazil: 'Brazil',
      japan: 'Japan'
    }
  end

  it 'return array of movies' do
    countrys.each do |key, _val|
      expect(testing_obj.send(key)).to be_a_array_of(MovieIndustry::Movie)
    end
  end

  it 'return select movies with specified country' do
    countrys.each do |key, val|
      testing_obj.send(key).map(&:country).all? { |e| expect(e).to eq(val) }
    end
  end
end
