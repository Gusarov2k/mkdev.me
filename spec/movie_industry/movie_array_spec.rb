RSpec.describe MovieIndustry::MovieArray do
  let(:movies)      { MovieIndustry::MovieCollection.new('./spec/fixtures/movies.txt') }
  let(:movie_array) { described_class.new(movies.all, movies.existing_genres) }

  describe 'Metaprogramming genres methods' do
    let(:genres) do
      {
        action: 'Action',
        crime: 'Crime',
        drama: 'Drama'
      }
    end

    it 'return array of movies' do
      genres.each do |key, _val|
        expect(movie_array.send(key)).to be_a_array_of(MovieIndustry::Movie)
      end
    end

    it 'return select movies with specified genre' do
      genres.each do |key, val|
        movie_array.send(key).map(&:genre).all? { |e| expect(e).to include(val) }
      end
    end
  end

  describe 'Metaprogramming country methods' do
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
        expect(movie_array.send(key)).to be_a_array_of(MovieIndustry::Movie)
      end
    end

    it 'return select movies with specified country' do
      countrys.each do |key, val|
        movie_array.send(key).map(&:country).all? { |e| expect(e).to eq(val) }
      end
    end
  end
end
