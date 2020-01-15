RSpec.describe Movie do
  subject { Movie.new(*input) }

  let(:input) { [movie_collection, params] }
  let(:movie_collection) { double }
  let(:params) { attributes_for(:movie) }
  let(:movie) { subject }

  describe '#new' do
    context 'when all good' do
      it { is_expected.to be_an_instance_of(Movie) }
      its(:movie_collection) { is_expected.to eq movie_collection }
      it 'creates movie instance with methods from all valid params' do
        params.each do |key, value|
          expect(movie.send(key)).to eq value
        end
      end
    end

    context 'when wrong number of arguments' do
      let(:input) { nil }
      it { expect { subject }.to raise_error(ArgumentError) }
    end

    context 'when invalid keys in params' do
      let(:params) { { invalid_key: 'some value', other_invalid_key: 'junk' } }
      it 'creates instance without any methods from params' do
        params.each do |key, _value|
          expect { movie.send(key) }.to raise_error(NoMethodError)
        end
      end
    end
  end
end
