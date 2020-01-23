RSpec.describe MovieCollection do
  let(:file_name)        { './spec/fixtures/movies.txt' }
  let(:movie_collection) { described_class.new(file_name) }
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

    context 'when all good' do
      let(:file_name) { './spec/fixtures/one_line_movies.txt' }

      it { is_expected.to be_an_instance_of(described_class) }
      its(:file_name) { is_expected.to eq file_name }
    end

    context 'when file not exists' do
      let(:file_name) { './never_exists_file.txt' }

      it { expect { new }.to raise_error(Errno::ENOENT) }
    end
  end

  describe '#all' do
    subject(:movies) { movie_collection.all }

    context 'when file contens movies' do
      let(:file_name) { './spec/fixtures/one_line_movies.txt' }
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

      it { is_expected.to be_a_array_of(Movie) }

      it 'return movie instance with data from file' do
        expect(movies.first).to have_attributes(movie_params)
      end
    end

    context 'when file is empty' do
      let(:file_name) { './spec/fixtures/empty_file.txt' }

      it { is_expected.to eq [] }
    end

    context 'when one movie created in 1900-1945 in the file' do
      let(:file_name) { './spec/fixtures/one_ancient_movie.txt' }

      it { is_expected.to be_a_array_of(AncientMovie) }
    end

    context 'when one movie created in 1945-1968 in the file' do
      let(:file_name) { './spec/fixtures/one_classic_movie.txt' }

      it { is_expected.to be_a_array_of(ClassicMovie) }
    end

    context 'when one movie created in 1968-2000 in the file' do
      let(:file_name) { './spec/fixtures/one_modern_movie.txt' }

      it { is_expected.to be_a_array_of(ModernMovie) }
    end

    context 'when one movie created after 2000 in the file' do
      let(:file_name) { './spec/fixtures/one_new_movie.txt' }

      it { is_expected.to be_a_array_of(NewMovie) }
    end
  end

  describe '#sort_by' do
    context 'when call with symbol' do
      subject(:sorted) { movie_collection.sort_by(:year) }

      it { is_expected.to be_a_array_of(Movie) }

      it 'sorts movies by year' do
        expect(sorted.map(&:year)).to eq [1957, 1972, 1974, 1994, 2008]
      end
    end

    context 'when call with block' do
      subject(:sorted) { movie_collection.sort_by { |m| m.year.to_s } }

      it { is_expected.to be_a_array_of(Movie) }

      it 'sorts movies by year like in symbol case' do
        expect(sorted.map(&:year)).to eq [1957, 1972, 1974, 1994, 2008]
      end
    end
  end

  describe '#select' do
    context 'when call with hash' do
      subject(:list) { movie_collection.select(country: 'USA') }

      it { is_expected.to be_a_array_of(Movie) }

      it 'returns only movies produced in USA' do
        expect(list).to all have_attributes(country: 'USA')
      end
    end

    context 'when call with block' do
      subject(:list) { movie_collection.select { |m| m.country == 'USA' } }

      it { is_expected.to be_a_array_of(Movie) }

      it 'returns only movies produced in USA like in symbol case' do
        expect(list).to all have_attributes(country: 'USA')
      end
    end
  end

  describe '#filter' do
    context 'when movie with given filters exists' do
      subject(:list) { movie_collection.filter(genre: 'Crime', year: (1993..1995), title: /The Shawshank/i) }

      it { is_expected.to be_a_array_of(Movie) }

      it 'Select The Shawshank Redemption Movie' do
        expect(list.first).to have_attributes(movie_params)
      end
    end

    context 'when movie with given filters not exists' do
      subject(:list) { movie_collection.filter(year: 21) }

      it { is_expected.to eq [] }
    end
  end

  describe '#stats' do
    context 'when call with valid arguments' do
      subject(:stats) { movie_collection.stats(:director) }

      it 'returns the hash with directors and his movis count' do
        expect(stats).to eq(
          'Frank Darabont' => 1,
          'Francis Ford Coppola' => 2,
          'Christopher Nolan' => 1,
          'Sidney Lumet' => 1
        )
      end
    end

    context 'when call with not-existing field' do
      subject { movie_collection.stats(not_existing: 'junk') }

      it { is_expected.to eq(nil => File.read(file_name).each_line.count) }
    end
  end

  describe '#existing_genres' do
    subject(:genres) { movie_collection.existing_genres }

    it 'returns all genres existing in movie_collection' do
      expect(genres).to eq %w[Action Crime Drama]
    end
  end
end
