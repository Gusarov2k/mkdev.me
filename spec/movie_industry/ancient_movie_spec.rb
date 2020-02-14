RSpec.describe MovieIndustry::AncientMovie do
  describe '#to_s' do
    subject { movie.to_s }

    let(:movie) { described_class.new(title: 'Modern Times', year: 1936) }

    it { is_expected.to eq 'Modern Times - old movie (1936 year)' }
  end
end
