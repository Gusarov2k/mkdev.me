RSpec.describe AncientMovie do
  it_behaves_like 'Movie children'

  describe '#to_s' do
    subject { movie.to_s }

    let(:movie) { described_class.new(nil, title: 'Modern Times', year: 1936) }

    it { is_expected.to eq 'Modern Times - old movie (1936 year)' }
  end
end
