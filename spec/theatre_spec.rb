RSpec.describe Theatre do
  let(:movie_collection) { MovieCollection.new('./spec/fixtures/theatre_movies.txt') }
  let(:theatre)          { described_class.new(movie_collection) }

  describe '.new' do
    subject { described_class.new(movie_collection) }

    it { is_expected.to be_a(described_class) }
  end

  describe '#show' do
    context 'when call in the morning' do
      subject(:show) { theatre.show(:morning) }

      Timecop.freeze(Time.new(2011, 1, 15, 15, 0)) do
        it { is_expected.to output('Now showing: Ancient Crime - old movie (1932 year) 15:00-17:22').to_stdout }
      end
    end

    context 'when call in the day' do
      subject(:show) { theatre.show(:day) }

      Timecop.freeze(Time.new(2011, 1, 15, 15, 0)) do
        it { is_expected.to output('Now showing: Modern Comedy - modern movie: stars Henry Fonda, Lee J. Cobb 15:00-16:36').to_stdout } # rubocop:disable Layout/LineLength
      end
    end

    context 'when call in the evening' do
      subject(:show) { theatre.show(:evening) }

      Timecop.freeze(Time.new(2011, 1, 15, 15, 0)) do
        it { is_expected.to output('Now showing: New Film - new movie, released 6 years ago! 15:00-17:22').to_stdout }
      end
    end
  end

  describe '#when?' do
    context 'when move exists' do
      it { expect(theatre.when?('New Film')).to eq :evening }
      it { expect(theatre.when?('Modern Comedy')).to eq :day }
      it { expect(theatre.when?('Ancient Crime')).to eq :morning }
    end

    context 'when movie not found' do
      it {
        expect(theatre.when?('Not existing movie')).to
        raise_error(RuntimeError, 'There is no "Not existing movie" found')
      }
    end
  end
end
