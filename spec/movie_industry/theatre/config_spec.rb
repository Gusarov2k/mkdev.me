RSpec.describe MovieIndustry::Theatre::Config do
  let(:config) do
    MovieIndustry::Theatre::ConfigBuilder.new do
      hall :red, title: 'Красный зал', places: 100
      hall :blue, title: 'Синий зал', places: 50

      period '09:00'..'11:00' do
        description 'Утренний сеанс'
        filters genre: 'Comedy', year: 1900..1980
        price 10
        hall :red, :blue
      end

      period '16:00'..'20:00' do
        description 'Вечерний сеанс'
        filters genre: %w[Action Drama], year: 2007..Time.now.year
        price 20
        hall :red, :blue
      end
    end.config
  end

  describe '#choose_period' do
    subject(:choose_period) { config.choose_period(time: Time.parse('9:01')) }

    context 'when period exists' do
      it { expect(choose_period).to be_an_instance_of(MovieIndustry::Theatre::Period) }
      it { expect(choose_period.description).to eq 'Утренний сеанс' }
    end

    context 'when period not exists' do
      it { expect(config.choose_period(time: Time.parse('11:01'))).to be_nil }
    end

    context 'when filtering by hall' do
      let(:config) do
        MovieIndustry::Theatre::ConfigBuilder.new do
          hall :red, title: 'Красный зал', places: 100
          hall :blue, title: 'Синий зал', places: 50

          period '09:00'..'11:00' do
            description 'Комедии в красном зале'
            filters genre: 'Comedy', year: 1900..1980
            price 10
            hall :red
          end

          period '09:00'..'11:00' do
            description 'Экшн-Драммы'
            filters genre: %w[Action Drama], year: 2007..Time.now.year
            price 20
            hall :blue
          end
        end.config
      end

      let(:choose_red) { config.choose_period(time: Time.parse('9:01'), hall: :red) }

      it { expect(choose_red.description).to eq 'Комедии в красном зале' }
    end
  end

  describe '#find_movie_period' do
    let(:movie_1) { MovieIndustry::Movie.new(nil, genre: 'Comedy', year: 1901) }
    let(:movie_2) { MovieIndustry::Movie.new(nil, genre: 'Drama', year: 2008) }
    let(:movie_3) { MovieIndustry::Movie.new(nil, genre: 'Drama', year: 2000) }

    context 'when period exists' do
      it { expect(config.find_movie_period(movie_1)).to be_an_instance_of(MovieIndustry::Theatre::Period) }
      it { expect(config.find_movie_period(movie_1).description).to eq 'Утренний сеанс' }
      it { expect(config.find_movie_period(movie_2)).to be_an_instance_of(MovieIndustry::Theatre::Period) }
      it { expect(config.find_movie_period(movie_2).description).to eq 'Вечерний сеанс' }
    end

    context 'when period not exists' do
      it { expect(config.find_movie_period(movie_3)).to be_nil }
    end
  end

  describe '#existing_halls' do
    it { expect(config.existing_halls).to include(:red, :blue) }
  end
end
