RSpec.describe Netflix do
  let(:movie_collection) { MovieCollection.new('./spec/fixtures/netflix_movies.txt') }
  let(:netflix)          { described_class.new(movie_collection) }

  describe '.new' do
    subject { described_class.new(movie_collection) }

    it { is_expected.to be_a(described_class) }

    context 'when initial balance not set' do
      its(:balance) { is_expected.to eq 0 }
    end

    context 'when creates with balance' do
      subject { described_class.new(movie_collection, balance) }

      let(:balance) { 12.45 }

      its(:balance) { is_expected.to eq balance }
    end
  end

  describe '#pay' do
    subject { netflix.pay(25) }

    context 'when pay to zero balance' do
      its(:balance) { is_expected.to eq 25 }
    end

    context 'when pay to not zero balance' do
      let(:netflix) { described_class.new(movie_collection, 5) }

      its(:balance) { is_expected.to eq 30 }
    end
  end

  describe '#how_much?' do
    context 'when AncientMovie' do
      it { expect(netflix.how_much?('Ancient Crime')).to eq 1 }
    end

    context 'when ClassicMovie' do
      it { expect(netflix.how_much?('Classic Drama')).to eq 1.5 }
    end

    context 'when ModernMovie' do
      it { expect(netflix.how_much?('Modern Drama')).to eq 3 }
    end

    context 'when NewMovie' do
      it { expect(netflix.how_much?('New Film')).to eq 5 }
    end

    context 'when movie not found' do
      it {
        expect(netflix.how_much?('Not existing movie')).to
        raise_error(RuntimeError, 'There is no "Not existing movie" found')
      }
    end
  end

  describe '#show' do
    context 'when AncientMovie' do
      subject(:show) { netflix.show(genre: 'Comedy', period: :ancient) }

      let(:netflix) { described_class.new(movie_collection, 100) }

      it 'bills money' do
        start_balance = netflix.balance
        show
        expect(start_balance - netflix.balance).to eq 1
      end

      Timecop.freeze(Time.new(2011, 1, 15, 15, 0)) do
        it { is_expected.to output('Now showing: Ancient Comedy - old movie (1912 year) 15:00-17:55').to_stdout }
      end
    end

    context 'when ClassicMovie' do
      subject(:show) { netflix.show(genre: 'Comedy', period: :classic) }

      let(:netflix) { described_class.new('./spec/fixtures/classic_movies.txt', 100) }

      it 'bills money' do
        start_balance = netflix.balance
        show
        expect(start_balance - netflix.balance).to eq 1.5
      end

      Timecop.freeze(Time.new(2011, 1, 15, 15, 0)) do
        it { is_expected.to output('Now showing: Movie1 - classic movie, director Greatest Director (Movie2, Movie3, Movie4, Movie5, Movie6, Movie7, Movie8, Movie9, Movie10, Movie11) 15:00-16:36').to_stdout } # rubocop:disable Layout/LineLength
      end
    end

    context 'when ModernMovie' do
      subject(:show) { netflix.show(genre: 'Comedy', period: :modern) }

      let(:netflix) { described_class.new(movie_collection, 100) }

      it 'bills money' do
        start_balance = netflix.balance
        show
        expect(start_balance - netflix.balance).to eq 3
      end

      Timecop.freeze(Time.new(2011, 1, 15, 15, 0)) do
        it { is_expected.to output('Now showing: Modern Comedy - modern movie: stars Henry Fonda, Lee J. Cobb 15:00-16:36').to_stdout } # rubocop:disable Layout/LineLength
      end
    end

    context 'when NewMovie' do
      subject(:show) { netflix.show(genre: 'Crime', period: :new) }

      let(:netflix) { described_class.new(movie_collection, 100) }

      it 'bills money' do
        start_balance = netflix.balance
        show
        expect(start_balance - netflix.balance).to eq 5
      end

      Timecop.freeze(Time.new(2011, 1, 15, 15, 0)) do
        it { is_expected.to output('Now showing: New Film - new movie, released 6 years ago! 15:00-17:22').to_stdout }
      end
    end

    context 'when not enough money' do
      subject(:show) { netflix.show }

      let(:netflix) { described_class.new(movie_collection, 0.3) }

      it { is_expected.to raise_error(RuntimeError, 'There is not enough money. Your balance $0.3') }
    end
  end
end
