RSpec.describe NewMovie do
  describe '#to_s' do
    subject { movie.to_s }

    let(:movie) { described_class.new(nil, title: 'Squad: The Enemy Within', year: 2010) }

    Timecop.freeze(Date.new(2015, 1, 15)) do
      it { is_expected.to eq 'Squad: The Enemy Within - new movie, released 5 years ago!' }
    end
  end
end
