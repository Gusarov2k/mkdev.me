RSpec.describe ClassicMovie do
  it_behaves_like 'Movie children'

  describe '#to_s' do
    subject { movie.to_s }

    let(:movie_collection) { MovieCollection.new('./spec/fixtures/classic_movies.txt') }
    let(:movie)            { movie_collection.select(title: 'Movie1') }

    it { is_expected.to eq('Movie1 - classic movie, director Greatest Director (Movie2, Movie3, Movie4, Movie5, Movie6, Movie7, Movie8, Movie9, Movie10, Movie11)') } # rubocop:disable Layout/LineLength
  end
end
