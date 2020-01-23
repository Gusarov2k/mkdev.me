RSpec.describe NewMovie do
  describe '#to_s' do
    subject { movie.to_s }

    let(:movie) { described_class.new(nil, title: 'Squad: The Enemy Within', year: 2010) }

    before { Timecop.freeze(Time.local(2015, 9, 1, 10, 5, 0)) }

    it { is_expected.to eq 'Squad: The Enemy Within - new movie, released 5 years ago!' }
  end
end
