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

  describe '#period_by_time' do
    subject(:period_by_time) { config.period_by_time(Time.parse('9:01')) }

    context 'when period exists' do
      it { expect(period_by_time).to be_an_instance_of(MovieIndustry::Theatre::Period) }
      it { expect(period_by_time.description).to eq 'Утренний сеанс' }
    end

    context 'when period not exists' do
      it { expect(config.period_by_time(Time.parse('11:01'))).to be_nil }
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
end
