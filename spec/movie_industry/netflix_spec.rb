RSpec.describe MovieIndustry::Netflix do
  let(:movie_collection) { MovieIndustry::MovieCollection.new('./spec/fixtures/netflix_movies.txt') }
  let(:netflix)          { described_class.new(movie_collection) }

  before do
    described_class.setup_cashbox
    described_class.take('Bank')
  end

  describe '.new' do
    context 'when initial balance not set' do
      subject(:new) { described_class.new(movie_collection) }

      it {
        new
        expect(described_class.cash).to eq Money.new(0, 'USD')
      }
    end

    context 'when creates with balance' do
      subject(:new) { described_class.new(movie_collection, balance) }

      let(:balance) { Money.new(1245, 'USD') }

      it {
        new
        expect(described_class.cash).to eq balance
      }
    end
  end

  describe '#pay' do
    it { expect { netflix.pay(Money.new(2500, 'USD')) }.to change(described_class, :cash).by(Money.new(2500, 'USD')) }
    it { expect { netflix.pay(Money.new(-100, 'USD')) }.to raise_error(RuntimeError, 'You can’t reduce balance') }
  end

  describe '#how_much?' do
    context 'when movie found' do
      it { expect(netflix.how_much?('Ancient Crime')).to eq Money.new(100, 'USD') }
      it { expect(netflix.how_much?('Classic Drama')).to eq Money.new(150, 'USD') }
      it { expect(netflix.how_much?('Modern Drama')).to eq Money.new(300, 'USD') }
      it { expect(netflix.how_much?('New Film')).to eq Money.new(500, 'USD') }
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
      subject(:show) { netflix.show(genre: 'Comedy', period: /Ancient/) }

      let!(:netflix) { described_class.new(movie_collection, Money.new(100_00, 'USD')) }

      it { expect { show }.to change(described_class, :cash).by(Money.new(-100, 'USD')) }
      it { expect { show }.to output("Now showing: Ancient Comedy - old movie (1912 year) 15:00-17:55\n").to_stdout }
    end

    context 'when ClassicMovie' do
      subject(:show) { netflix.show(genre: 'Comedy', period: /Classic/) }

      let!(:netflix) { described_class.new(movie_collection, Money.new(100_00, 'USD')) }

      it { expect { show }.to change(described_class, :cash).by(Money.new(-150, 'USD')) }

      it {
        expect { show }
          .to output("Now showing: Classic Comedy - classic movie, director Christopher Nolan (his 2 another films) 15:00-17:32\n")
          .to_stdout
      }
    end

    context 'when ModernMovie' do
      subject(:show) { netflix.show(genre: 'Comedy', period: /Modern/) }

      let!(:netflix) { described_class.new(movie_collection, Money.new(100_00, 'USD')) }

      it { expect { show }.to change(described_class, :cash).by(Money.new(-300, 'USD')) }

      it {
        expect { show }
          .to output("Now showing: Modern Comedy - modern movie: stars Henry Fonda, Lee J. Cobb 15:00-16:36\n")
          .to_stdout
      }
    end

    context 'when NewMovie' do
      subject(:show) { netflix.show(genre: 'Crime', period: /New/) }

      let!(:netflix) { described_class.new(movie_collection, Money.new(100_00, 'USD')) }

      it { expect { show }.to change(described_class, :cash).by(Money.new(-500, 'USD')) }

      it {
        expect { show }.to output("Now showing: New Film - new movie, released 3 years ago! 15:00-17:22\n").to_stdout
      }
    end

    context 'when not enough money' do
      subject(:show) { netflix.show }

      let(:netflix) { described_class.new(movie_collection, Money.new(30, 'USD')) }

      it { expect { show }.to raise_error(RuntimeError, 'There is not enough money. Your balance $0.30') }
    end
  end
end
