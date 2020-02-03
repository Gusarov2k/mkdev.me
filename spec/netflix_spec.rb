RSpec.describe Netflix do
  let(:movie_collection) { MovieCollection.new('./spec/fixtures/netflix_movies.txt') }
  let(:netflix)          { described_class.new(movie_collection) }

  describe '.new' do
    context 'when initial balance not set' do
      subject { described_class.new(movie_collection) }

      its(:balance) { is_expected.to eq 0 }
    end

    context 'when creates with balance' do
      subject { described_class.new(movie_collection, balance) }

      let(:balance) { 12.45 }

      its(:balance) { is_expected.to eq balance }
    end
  end

  describe '#pay' do
    it { expect { netflix.pay(25) }.to change(netflix, :balance).by(25) }
    it { expect { netflix.pay(-1) }.to raise_error(RuntimeError, 'You can’t reduce balance') }
  end

  describe '#how_much?' do
    context 'when movie found' do
      it { expect(netflix.how_much?('Ancient Crime')).to eq 1 }
      it { expect(netflix.how_much?('Classic Drama')).to eq 1.5 }
      it { expect(netflix.how_much?('Modern Drama')).to eq 3 }
      it { expect(netflix.how_much?('New Film')).to eq 5 }
    end

    context 'when movie not found' do
      it {
        expect { netflix.how_much?('Not existing movie') }
          .to raise_error(RuntimeError, "There is no 'Not existing movie' found")
      }
    end
  end

  describe '#show' do
    before { Timecop.freeze(Time.new(2011, 1, 15, 15, 0)) }

    context 'when AncientMovie' do
      subject(:show) { netflix.show(genre: 'Comedy', period: :ancient) }

      let(:netflix) { described_class.new(movie_collection, 100) }

      it { expect { show }.to change(netflix, :balance).by(-1) }
      it { expect { show }.to output("Now showing: Ancient Comedy - old movie (1912 year) 15:00-17:55\n").to_stdout }
    end

    context 'when ClassicMovie' do
      subject(:show) { netflix.show(genre: 'Comedy', period: :classic) }

      let(:netflix) { described_class.new(movie_collection, 100) }

      it { expect { show }.to change(netflix, :balance).by(-1.5) }

      it {
        expect { show }
          .to output("Now showing: Classic Comedy - classic movie, director Christopher Nolan (his 2 another films) 15:00-17:32\n")
          .to_stdout
      }
    end

    context 'when ModernMovie' do
      subject(:show) { netflix.show(genre: 'Comedy', period: :modern) }

      let(:netflix) { described_class.new(movie_collection, 100) }

      it { expect { show }.to change(netflix, :balance).by(-3) }

      it {
        expect { show }
          .to output("Now showing: Modern Comedy - modern movie: stars Henry Fonda, Lee J. Cobb 15:00-16:36\n")
          .to_stdout
      }
    end

    context 'when NewMovie' do
      subject(:show) { netflix.show(genre: 'Crime', period: :new) }

      let(:netflix) { described_class.new(movie_collection, 100) }

      it { expect { show }.to change(netflix, :balance).by(-5) }

      it {
        expect { show }.to output("Now showing: New Film - new movie, released 3 years ago! 15:00-17:22\n").to_stdout
      }
    end

    context 'when not enough money' do
      subject(:show) { netflix.show }

      let(:netflix) { described_class.new(movie_collection, 0.3) }

      it { expect { show }.to raise_error(RuntimeError, 'There is not enough money. Your balance $0.3') }
    end
  end
end
