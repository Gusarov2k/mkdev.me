RSpec.describe ClassicMovie do
  describe '#to_s' do
    subject { movie.to_s }

    let(:movie) { described_class.new(nil, title: 'Classic Comedy', director: 'Christopher Nolan') }

    it { is_expected.to eq('Classic Comedy - classic movie, director Christopher Nolan (his 10 another films)') }
  end
end
