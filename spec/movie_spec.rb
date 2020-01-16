RSpec.describe Movie do
  let(:input)            { [movie_collection, params] }
  let(:movie_collection) { double }
  let(:existing_genres)  { %w[Crime Drama Action] }
  let(:params)           { attributes_for(:movie) }
  let(:movie)            { described_class.new(*input) }

  before do
    allow(movie_collection).to receive(:file_name).and_return('movies.txt')
    allow(movie_collection).to receive(:existing_genres).and_return(existing_genres)
  end

  describe '#new' do
    subject { described_class.new(*input) }

    context 'when all good' do
      its(:itself) { should be_an_instance_of(described_class) }
      its(:movie_collection) { should eq movie_collection }
      it 'creates movie instance with methods from all valid params' do
        params.each do |key, value|
          expect(movie.send(key)).to eq value
        end
      end
    end

    context 'when wrong number of arguments' do
      let(:input) { nil }
      its(:itself) { will raise_error(ArgumentError) }
    end

    context 'when invalid keys in params' do
      let(:params) { { invalid_key: 'some value', other_invalid_key: 'junk' } }
      it 'creates instance without any methods from params' do
        params.each do |key, _value|
          expect { movie.send(key) }.to raise_error(NoMethodError)
        end
      end
    end
  end

  describe '#to_s' do
    let(:title)           { attributes_for(:movie)[:title] }
    let(:release_at)      { attributes_for(:movie)[:release_at] }
    let(:genre)           { attributes_for(:movie)[:genre] }
    let(:duration)        { attributes_for(:movie)[:duration] }
    let(:params)          { { title: title, release_at: release_at, genre: genre, duration: duration } }
    let(:expected_string) { "#{title} (#{release_at}; #{genre.join('/')}) - #{duration} min" }
    subject { movie.to_s }

    its(:itself) { should eq(expected_string) }
  end

  describe '#has_genre?' do
    let(:movie_gengres)   { %w[Crime Drama] }
    let(:params)          { { genre: movie_gengres } }
    let(:err_msg)         { "There is no genre #{testing_genre} in #{movie_collection.file_name}" }
    subject { movie.has_genre?(testing_genre) }

    context 'when movie has testing genre' do
      let(:testing_genre) { 'Drama' }
      its(:itself) { should be_truthy }
    end

    context 'when movie has no testing genre' do
      let(:testing_genre) { 'Action' }
      its(:itself) { should be_falsey }
    end

    context 'when testing genre not present in movie_collection existing_genres' do
      let(:testing_genre) { 'Opera' }
      its(:itself) { will raise_error(RuntimeError, err_msg) }
    end

    context 'when movie_collection has empty existing_genres' do
      let(:existing_genres) { nil }
      let(:testing_genre)   { 'Opera' }
      its(:itself) { will raise_error(NoMethodError) }
    end

    context 'when testing genre is nil' do
      let(:testing_genre) { nil }
      its(:itself) { will raise_error(RuntimeError, err_msg) }
    end
  end

  describe '#matches?' do
    let(:pattern) { double }
    subject { movie.matches?(field, pattern) }

    context 'when field is not Array' do
      let(:field) { :title }

      it 'comparing pattern and field value with "===" method' do
        expect(pattern).to receive(:===).with(movie.send(field))
        subject
      end
    end

    context 'when field is Array' do
      let(:field) { :genre }
      let(:value) { movie.send(field) }

      it 'comparing field value and pattern with "any?" method' do
        expect(value).to receive(:any?).with(pattern)
        subject
      end
    end

    context 'when wrong number of arguments' do
      subject { movie.matches? }
      its(:itself) { will raise_error(ArgumentError) }
    end
  end

  describe '#month' do
    subject { movie.month }

    context 'when movie has release_at value' do
      let(:date)   { FFaker::Time.date }
      let(:params) { { release_at: date } }
      its(:itself) { should eq date.strftime('%B') }
    end

    context 'when movie has not release_at value' do
      let(:params) { {} }
      its(:itself) { will raise_error(NoMethodError) }
    end

    context 'when wrong number of arguments' do
      subject { movie.month(:some_arg) }
      its(:itself) { will raise_error(ArgumentError) }
    end
  end
end
