RSpec.describe MovieCollection do
  let(:file_name)                 { './spec/fixtures/movies.txt' }
  let!(:movie_collection)         { described_class.new(file_name) }
  let!(:instance_variable_movies) { movie_collection.instance_variable_get(:@movies) }
  let(:movie_params) do
    {
      imdb_link: 'http://imdb.com/title/tt0111161/?ref_=chttp_tt_1',
      title: 'The Shawshank Redemption',
      year: 1994,
      country: 'USA',
      release_at: Date.new(1994, 10, 14),
      genre: %w[Crime Drama],
      duration: 142,
      rate: '9.3',
      director: 'Frank Darabont',
      star_actors: ['Tim Robbins', 'Morgan Freeman', 'Bob Gunton']
    }
  end

  describe '.new' do
    subject(:new) { described_class.new(file_name) }

    let(:file_name) { './spec/fixtures/one_line_movies.txt' }
    let(:movie)     { subject.instance_variable_get(:@movies).first }

    context 'when all good' do
      it { is_expected.to be_an_instance_of(described_class) }
      its(:file_name) { is_expected.to eq file_name }

      it 'creates Array of Movie' do
        expect(new.instance_variable_get(:@movies)).to(be_any { |e| e.is_a?(Movie) })
      end

      it 'parse txt file and creates valid Movie' do
        movie_params.each do |key, value|
          expect(movie.send(key)).to eq value
        end
      end
    end

    context 'when wrong number of arguments' do
      subject { described_class.new }

      its(:itself) { will raise_error(ArgumentError) }
    end
  end

  describe '#all' do
    subject { movie_collection.all }

    it { is_expected.to eq instance_variable_movies }
  end

  describe '#sort_by' do
    subject(:all) { movie_collection.sort_by(arg) }

    context 'when call with symbol' do
      let(:arg) { :duration }

      it 'calls sort_by for instance_variable @movies with arg converted to Proc' do
        expect(instance_variable_movies).to receive(:sort_by) do |*_args, &block|
          expect(arg.to_proc).to eq block
        end
        all
      end
    end

    context 'when call with block' do
      let(:arg) { proc { 'hi' } }

      it 'calls sort_by for instance_variable @movies with given block' do
        expect(instance_variable_movies).to receive(:sort_by) do |*_args, &block|
          expect(arg).to eq block
        end
        all
      end
    end

    context 'when call with whong argument type' do
      let(:arg) { 'duration' }

      its(:itself) { will raise_error(TypeError) }
    end
  end

  describe '#select' do
    context 'when call with hash' do
      subject(:list) { movie_collection.select(country: 'USA') }

      it 'calls select for instance_variable @movies and pass hash converted to Proc' do
        expect(instance_variable_movies).to receive(:select) do |*_args, &block|
          expect(block).to be_an_instance_of(Proc)
        end
        list
      end
    end

    context 'when call with block' do
      subject(:list) { movie_collection.select { |m| m.genre.include?('Comedy') } }

      it 'calls select for instance_variable @movies and pass given block' do
        expect(instance_variable_movies).to receive(:select) do |*_args, &block|
          expect(block).to be_an_instance_of(Proc)
        end
        list
      end
    end

    context 'when call with whong argument type' do
      subject { movie_collection.select('duration') }

      its(:itself) { will raise_error(NoMethodError) }
    end
  end

  describe '#filter' do
    context 'when call with valid arguments' do
      subject { movie_collection.filter(genre: 'Crime', year: (1993..1995), title: /The Shawshank/i) }

      let(:movie) { subject.first }

      it 'Select The Shawshank Redemption Movie' do
        movie_params.each do |key, value|
          expect(movie.send(key)).to eq value
        end
      end
    end

    context 'when call with not-existing field' do
      subject { movie_collection.filter(not_existing: 'junk') }

      its(:itself) { will raise_error(NoMethodError) }
    end
  end

  describe '#stats' do
    context 'when call with valid arguments' do
      subject { movie_collection.stats(:director) }

      let(:expected_result) do
        {
          'Frank Darabont' => 1,
          'Francis Ford Coppola' => 2,
          'Christopher Nolan' => 1,
          'Sidney Lumet' => 1
        }
      end

      it { is_expected.to eq expected_result }
    end

    context 'when call with not-existing field' do
      subject { movie_collection.stats(not_existing: 'junk') }

      let(:expected_result) { { nil => File.read(file_name).each_line.count } }

      it { is_expected.to eq expected_result }
    end
  end

  describe '#existing_genres' do
    subject { movie_collection.existing_genres }

    it { is_expected.to eq %w[Action Crime Drama] }
  end
end
