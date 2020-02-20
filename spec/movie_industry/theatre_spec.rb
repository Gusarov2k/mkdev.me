RSpec.describe MovieIndustry::Theatre do
  let(:movie_collection) { MovieIndustry::MovieCollection.new('./spec/fixtures/theatre_movies.txt') }
  let(:theatre)          { described_class.new(movie_collection) }
  let(:dsl_theatre) do
    described_class.new do
      hall :red, title: 'Красный зал', places: 100
      hall :blue, title: 'Синий зал', places: 50
      hall :green, title: 'Зелёный зал (deluxe)', places: 12

      period '09:00'..'11:00' do
        description 'Утренний сеанс'
        filters genre: 'Comedy', year: 1900..1980
        price 10
        hall :red, :blue
      end

      period '11:00'..'16:00' do
        description 'Спецпоказ'
        title 'The Terminator'
        price 50
        hall :green
      end

      period '16:00'..'20:00' do
        description 'Вечерний сеанс'
        filters genre: %w[Action Drama], year: 2007..Time.now.year
        price 20
        hall :red, :blue
      end

      period '19:00'..'22:00' do
        description 'Вечерний сеанс для киноманов'
        filters year: 1900..1945, exclude_country: 'USA'
        price 30
        hall :green
      end
    end
  end

  before do
    described_class.instance_eval do
      @periods = {}
      @halls = {}
    end
  end

  describe '.new' do
    it { expect(described_class.new(movie_collection).cash).to eq Money.new(0, 'USD') }

    context 'when DSL-config valid' do
      it { expect(dsl_theatre).to be_an_instance_of(described_class) }
    end

    describe 'when DSL-config has periods conflict' do
      let(:theatre_1) do
        described_class.new do
          hall :red, title: 'Красный зал', places: 100
          hall :blue, title: 'Синий зал', places: 50

          period '09:00'..'11:00' do
            description 'Утренний сеанс'
            filters genre: 'Comedy', year: 1900..1980
            price 10
            hall :red, :blue
          end

          period '10:00'..'16:00' do
            description 'Спецпоказ'
            title 'The Terminator'
            price 50
            hall :red
          end
        end
      end

      let(:theatre_2) do
        described_class.new do
          hall :red, title: 'Красный зал', places: 100
          hall :blue, title: 'Синий зал', places: 50

          period '09:00'..'11:00' do
            description 'Утренний сеанс'
            filters genre: 'Comedy', year: 1900..1980
            price 10
            hall :red, :blue
          end

          period '08:00'..'16:00' do
            description 'Утренник'
            title 'The Terminator'
            price 50
            hall :red
          end
        end
      end

      it { expect { theatre_1 }.to raise_error(RuntimeError, "Period 'Утренний сеанс' conflicts with 'Спецпоказ'") }
      it { expect { theatre_2 }.to raise_error(RuntimeError, "Period 'Утренний сеанс' conflicts with 'Утренник'") }
    end
  end

  describe '#show' do
    subject(:show) { theatre.show }

    context 'when call in the morning 4:00-12:00' do
      let(:str1) { 'Now showing: Ancient Crime - old movie (1932 year) 11:00-13:22' }
      let(:str2) { 'Now showing: Ancient Crime2 - old movie (1933 year) 11:00-13:22' }

      before { Timecop.freeze(Time.new(2011, 1, 15, 11, 0)) }

      it { expect { show }.to output(Regexp.union(str1, str2)).to_stdout }
      # it { show }
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

    context 'when call in the night 00:00-4:00 for DSL-config' do
      subject(:show) { dsl_theatre.show }

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

  describe '#buy_ticket' do
    subject(:buy) { theatre.buy_ticket('Ancient Crime') }

    it { expect { buy }.to output("You buy ticket to 'Ancient Crime'\n").to_stdout }

    context 'when movie in morning shedule' do
      it { expect { buy }.to change(theatre, :cash).by(Money.new(300, 'USD')) }
    end

    context 'when movie in day shedule' do
      subject(:buy) { theatre.buy_ticket('Modern Comedy') }

      it { expect { buy }.to change(theatre, :cash).by(Money.new(500, 'USD')) }
    end

    context 'when movie in evening shedule' do
      subject(:buy) { theatre.buy_ticket('New Film') }

      it { expect { buy }.to change(theatre, :cash).by(Money.new(1000, 'USD')) }
    end

    context 'when movie not in shedule' do
      subject(:buy) { theatre.buy_ticket('The Terminator') }

      it { expect { buy }.to raise_error(RuntimeError, "There is no 'The Terminator' in actual shedule") }
    end
  end
end
