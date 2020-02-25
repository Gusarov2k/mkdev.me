RSpec.describe MovieIndustry::Theatre::Period do
  let(:config_1) do
    MovieIndustry::Theatre::ConfigBuilder.new do
      hall :red, title: 'Красный зал', places: 100
      hall :blue, title: 'Синий зал', places: 50

      period '09:00'..'11:00' do
        description 'Утренний сеанс'
        filters genre: %w[Action Drama], year: 1900..1980
        title 'The Movie'
        price 10
        hall :red, :blue
      end

      period '12:00'..'13:00' do
        description 'НЕ Утренний сеанс'
        filters genre: 'Drama'
        price 20
        hall :red
      end
    end.config
  end

  let(:config_2) do
    MovieIndustry::Theatre::ConfigBuilder.new do
      hall :red, title: 'Красный зал', places: 100
      hall :blue, title: 'Синий зал', places: 50

      period '09:00'..'11:00' do
        description 'Утренний сеанс2'
        title 'The Movie'
        price 10
        hall :red, :blue
      end

      period '14:00'..'17:00' do
        description 'НЕ Утренний сеанс2'
        filters genre: 'Drama'
        price 20
        hall :red
      end
    end.config
  end

  let(:period_1) { config_1.periods.values.first }
  let(:period_2) { config_1.periods.values.last }
  let(:period_3) { config_2.periods.values.first }
  let(:period_4) { config_2.periods.values.last }

  describe '.new' do
    it { expect(period_1.price).to eq Money.new(1000, 'USD') }
    it { expect(period_1.filters).to include(genre: /Action|Drama/, year: 1900..1980) }
    it { expect(period_2.filters).to include(genre: /Drama/) }
  end

  describe '#intersect?' do
    # rubocop:disable RSpec/PredicateMatcher
    it { expect(period_1.intersect?(period_3)).to be_truthy }
    it { expect(period_1.intersect?(period_4)).to be_falsey }
    it { expect(period_2.intersect?(period_3)).to be_falsey }
    it { expect(period_2.intersect?(period_4)).to be_falsey }
    # rubocop:enable RSpec/PredicateMatcher
  end

  describe '#include?' do
    # rubocop:disable RSpec/PredicateMatcher
    it { expect(period_1.include?(Time.parse('9:01'))).to be_truthy }
    it { expect(period_1.include?(Time.parse('8:59'))).to be_falsey }
    # rubocop:enable RSpec/PredicateMatcher
  end

  describe '#matche_movie?(movie)' do
    let(:movie_1) { MovieIndustry::Movie.new(nil, genre: 'Comedy', year: 1901, title: 'The Movie') }
    let(:movie_2) { MovieIndustry::Movie.new(nil, genre: 'Drama', year: 2008) }

    # rubocop:disable RSpec/PredicateMatcher
    it 'return false then movie matched' do
      expect(period_1.matche_movie?(movie_1)).to be_falsey
    end

    it 'return true then movie NOT matched' do
      expect(period_2.matche_movie?(movie_2)).to be_truthy
    end
    # rubocop:enable RSpec/PredicateMatcher
  end

  describe 'glue_up_filters' do
    it { expect(period_1.glue_up_filters).to include(genre: /Action|Drama/, year: 1900..1980, title: 'The Movie') }
    it { expect(period_2.filters).to include(genre: /Drama/) }
    it { expect(period_3.glue_up_filters).to include(title: 'The Movie') }
  end
end
