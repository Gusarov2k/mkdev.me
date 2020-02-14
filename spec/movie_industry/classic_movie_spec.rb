RSpec.describe MovieIndustry::ClassicMovie do
  describe '#to_s' do
    subject { movie.to_s }

    let(:collection) { MovieIndustry::MovieCollection.new }
    let(:movie) { described_class.new(movie_collection: collection, title: 'Classic Comedy', director: 'Christopher Nolan') }

    before { allow(collection).to receive(:filter).and_return(Array.new(3, described_class)) }

    it { is_expected.to eq('Classic Comedy - classic movie, director Christopher Nolan (his 3 another films)') }
  end
end
