RSpec.describe MovieIndustry::ModernMovie do
  describe '#to_s' do
    subject { movie.to_s }

    let(:movie) { described_class.new(nil, title: 'Casino', star_actors: ['Robert De Niro', 'Sharon Stone']) }

    it { is_expected.to eq 'Casino - modern movie: stars Robert De Niro, Sharon Stone' }
  end
end
