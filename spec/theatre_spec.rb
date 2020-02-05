RSpec.describe Theatre do
  let(:movie_collection) { MovieCollection.new('./spec/fixtures/theatre_movies.txt') }
  let(:theatre)          { described_class.new(movie_collection) }

  describe '#show' do
    subject(:show) { theatre.show }

    context 'when call in the morning 4:00-12:00' do
      let(:str1) { 'Now showing: Ancient Crime - old movie (1932 year) 11:00-13:22' }
      let(:str2) { 'Now showing: Ancient Crime2 - old movie (1933 year) 11:00-13:22' }

      before { Timecop.freeze(Time.new(2011, 1, 15, 11, 0)) }

      it { expect { show }.to output(Regexp.union(str1, str2)).to_stdout }
    end

    context 'when call in the day 12:00-16:00' do
      before { Timecop.freeze(Time.new(2011, 1, 16, 15, 0)) }

      it { expect { show }.to output("Now showing: Modern Comedy - modern movie: stars Henry Fonda, Lee J. Cobb 15:00-16:36\n").to_stdout }
    end

    context 'when call in the evening 16:00-00:00' do
      before { Timecop.freeze(Time.new(2011, 1, 15, 19, 0)) }

      it { expect { show }.to output("Now showing: New Film - new movie, released 3 years ago! 19:00-21:22\n").to_stdout }
    end

    context 'when call in the night 00:00-4:00' do
      before { Timecop.freeze(Time.new(2011, 1, 15, 0, 30)) }

      it { expect { show }.to output("Sory, Theatre is closed now.\n").to_stdout }
    end
  end

  describe '#when?' do
    context 'when move exists' do
      it { expect(theatre.when?('New Film')).to eq :evening }
      it { expect(theatre.when?('Modern Comedy')).to eq :day }
      it { expect(theatre.when?('Ancient Crime')).to eq :morning }
      it { expect(theatre.when?('Never Film')).to be_nil }
    end

    context 'when movie not found' do
      it {
        expect { theatre.when?('Not existing movie') }.to raise_error(RuntimeError, "There is no 'Not existing movie' found")
      }
    end
  end
end
