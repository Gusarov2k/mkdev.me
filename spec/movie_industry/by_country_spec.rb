RSpec.describe MovieIndustry::ByCountry do
  let(:testing_obj) { described_class.new(movies) }
  let(:movies)      { MovieIndustry::MovieCollection.new('./spec/fixtures/movies.txt') }
  let(:countrys) do
    {
      usa: 'USA',
      italy: 'Italy',
      france: 'France',
      brazil: 'Brazil',
      japan: 'Japan'
    }
  end

  context 'when country exists' do
    it 'return array of movies' do
      countrys.each do |key, _val|
        expect(testing_obj.send(key)).to be_a_array_of(MovieIndustry::Movie)
      end
    end

    it 'return select movies with specified country' do
      countrys.each do |key, val|
        testing_obj.send(key).map(&:country).all? { |e| expect(e).to eq(val) }
      end
    end
  end

  context 'when country not exists' do
    it { expect(testing_obj.nepal).to eq [] }
  end

  context 'when call with prohibited symbols in method name' do
    it { expect { testing_obj.nepal? }.to raise_error(NoMethodError) }
    it { expect { testing_obj.nepal! }.to raise_error(NoMethodError) }
    it { expect { testing_obj.nepal = 2 }.to raise_error(NoMethodError) }
  end

  context 'when call with args or block' do
    let(:msg) { "Country filter can't be called with args or block" }

    it { expect { testing_obj.nepal(true) }.to raise_error(ArgumentError, msg) }
    it { expect { testing_obj.nepal { puts 'vava la nepal' } }.to raise_error(ArgumentError, msg) }
  end
end
