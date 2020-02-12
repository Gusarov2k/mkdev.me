RSpec.describe MovieIndustry::Netflix do
  let(:movie_collection) { MovieIndustry::MovieCollection.new('./spec/fixtures/netflix_movies.txt') }
  let(:netflix)          { described_class.new(movie_collection) }

  before { described_class.take('Bank') }

  describe '.new' do
    context 'when initial balance not set' do
      subject(:new) { described_class.new(movie_collection) }

      its(:client_balance) { is_expected.to eq Money.new(0, 'USD') }
    end

    context 'when creates with balance' do
      subject(:new) { described_class.new(movie_collection, client_balance) }

      let(:client_balance) { Money.new(1245, 'USD') }

      its(:client_balance) { is_expected.to eq client_balance }
    end
  end

  describe '#pay' do
    it { expect { netflix.pay(Money.new(2500, 'USD')) }.to change(netflix, :client_balance).by(Money.new(2500, 'USD')) }
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

  describe '#define_filter' do
    context 'when from and block together' do
      subject(:define_filter) { netflix.define_filter(:newest_crime, from: :new_crime) { puts 'example' } }

      let!(:netflix) { described_class.new(movie_collection) }

      it { expect { define_filter }.to raise_error(RuntimeError, "From and block can't work together!") }
    end

    context 'when inherit from not existing filter' do
      subject(:define_filter) { netflix.define_filter(:newest_crime, from: :not_existing) }

      let!(:netflix) { described_class.new(movie_collection) }

      it { expect { define_filter }.to raise_error(KeyError, 'key not found: :not_existing') }
    end

    context 'when call without from or block' do
      subject(:define_filter) { netflix.define_filter(:newest_crime) }

      let!(:netflix) { described_class.new(movie_collection) }

      it { expect { define_filter }.to raise_error(RuntimeError, 'Wrong filter setup!') }
    end
  end

  describe '#show' do
    let(:netflix) { described_class.new(movie_collection, Money.new(100_00, 'USD')) }

    before { Timecop.freeze(Time.new(2011, 1, 15, 15, 0)) }

    context 'when AncientMovie' do
      subject(:show) { netflix.show(genre: 'Comedy', period: /Ancient/) }

      it { expect { show }.to change(described_class, :cash).by(Money.new(100, 'USD')) }
      it { expect { show }.to change(netflix, :client_balance).by(Money.new(-100, 'USD')) }
      it { expect { show }.to output("Now showing: Ancient Comedy - old movie (1912 year) 15:00-17:55\n").to_stdout }
    end

    context 'when ClassicMovie' do
      subject(:show) { netflix.show(genre: 'Comedy', period: /Classic/) }

      it { expect { show }.to change(described_class, :cash).by(Money.new(150, 'USD')) }
      it { expect { show }.to change(netflix, :client_balance).by(Money.new(-150, 'USD')) }

      it {
        expect { show }
          .to output("Now showing: Classic Comedy - classic movie, director Christopher Nolan (his 2 another films) 15:00-17:32\n")
          .to_stdout
      }
    end

    context 'when ModernMovie' do
      subject(:show) { netflix.show(genre: 'Comedy', period: /Modern/) }

      it { expect { show }.to change(described_class, :cash).by(Money.new(300, 'USD')) }
      it { expect { show }.to change(netflix, :client_balance).by(Money.new(-300, 'USD')) }

      it {
        expect { show }
          .to output("Now showing: Modern Comedy - modern movie: stars Henry Fonda, Lee J. Cobb 15:00-16:36\n")
          .to_stdout
      }
    end

    context 'when NewMovie' do
      subject(:show) { netflix.show(genre: 'Crime', period: /New/) }

      it { expect { show }.to change(described_class, :cash).by(Money.new(500, 'USD')) }
      it { expect { show }.to change(netflix, :client_balance).by(Money.new(-500, 'USD')) }

      it {
        expect { show }.to output("Now showing: New Film - new movie, released 3 years ago! 15:00-17:22\n").to_stdout
      }
    end

    context 'when not enough money' do
      subject(:show) { netflix.show }

      let(:netflix) { described_class.new(movie_collection, Money.new(30, 'USD')) }

      it { expect { show }.to raise_error(RuntimeError, 'There is not enough money. Your balance $0.30') }
    end

    context 'when block given' do
      subject(:show) { netflix.show { |m| m.genre.include?('Crime') && m.year > 2006 && m.title.include?('New Film') } }

      it {
        expect { show }.to output("Now showing: New Film - new movie, released 3 years ago! 15:00-17:22\n").to_stdout
      }
    end

    context 'when work with user filters' do
      subject(:show) { netflix.show(new_crime: true) }

      before do
        netflix.define_filter(:new_crime) do |m|
          m.genre.include?('Crime') &&
            m.year > 2006 &&
            m.title.include?('New Film')
        end
      end

      it {
        expect { show }.to output("Now showing: New Film - new movie, released 3 years ago! 15:00-17:22\n").to_stdout
      }
    end

    context 'when user filter with argument' do
      subject(:show) { netflix.show(new_crime: 2006) }

      before do
        netflix.define_filter(:new_crime) do |m, y|
          m.genre.include?('Crime') &&
            m.year > y &&
            m.title.include?('New Film')
        end
      end

      it {
        expect { show }.to output("Now showing: New Film - new movie, released 3 years ago! 15:00-17:22\n").to_stdout
      }
    end

    context 'when user filter inherit from user filter' do
      subject(:show) { netflix.show(newest_crime: true) }

      before do
        netflix.define_filter(:new_crime) do |m, y|
          m.genre.include?('Crime') &&
            m.year > y &&
            m.title.include?('New Film')
        end

        netflix.define_filter(:newest_crime, from: :new_crime, arg: 2006)
      end

      it {
        expect { show }.to output("Now showing: New Film - new movie, released 3 years ago! 15:00-17:22\n").to_stdout
      }
    end

    context 'when user and standart filters given' do
      subject(:show) { netflix.show(new_crime: true, title: 'New Film 3') }

      before { netflix.define_filter(:new_crime) { |m| m.genre.include?('Crime') && m.year > 2006 } }

      it {
        expect { show }.to output("Now showing: New Film 3 - new movie, released 2 years ago! 15:00-17:22\n").to_stdout
      }
    end

    context 'when user and standart filters given plus block' do
      subject(:show) { netflix.show(new_crime: 2006, duration: 143) { |m| m.year == 2009 } }

      before { netflix.define_filter(:new_crime) { |m, y| m.genre.include?('Crime') && m.year > y } }

      it {
        expect { show }.to output("Now showing: New Film 4 - new movie, released 2 years ago! 15:00-17:23\n").to_stdout
      }
    end
  end
end
