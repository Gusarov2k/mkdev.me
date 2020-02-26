RSpec.describe MovieIndustry::ByGenre do
  let(:testing_obj) { described_class.new(movies) }
  let(:movies)      { MovieIndustry::MovieCollection.new('./spec/fixtures/movies.txt') }
  let(:genres) do
    {
      action: 'Action',
      crime: 'Crime',
      drama: 'Drama'
    }
  end

  it 'return array of movies' do
    genres.each do |key, _val|
      expect(testing_obj.send(key)).to be_a_array_of(MovieIndustry::Movie)
    end
  end

  it 'return select movies with specified genre' do
    genres.each do |key, val|
      testing_obj.send(key).map(&:genre).all? { |e| expect(e).to include(val) }
    end
  end
end
