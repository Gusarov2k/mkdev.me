class Movie
  require_relative 'ancient_movie'
  require_relative 'classic_movie'
  require_relative 'modern_movie'
  require_relative 'new_movie'

  HEADERS = %i[imdb_link title year country release_at genre duration rate director star_actors].freeze
  MOVIE_PERIODS = {
    1900..1945 => AncientMovie,
    1945..1968 => ClassicMovie,
    1968..2000 => ModernMovie,
    2000.. => NewMovie
  }.freeze

  attr_reader(*HEADERS)
  attr_reader :movie_collection

  def initialize(movie_collection, **params)
    @movie_collection = movie_collection
    params.each { |key, value| instance_variable_set("@#{key}", value) }
  end

  def to_s
    "#{title} (#{release_at}; #{genre.join('/')}) - #{duration} min"
  end

  def has_genre?(attr)
    err_msg = "There is no genre #{attr} in #{movie_collection.file_name}"
    raise err_msg unless movie_collection.existing_genres.include?(attr)

    genre.include?(attr)
  end

  def matches?(field, pattern)
    value = send(field)
    value.is_a?(Array) ? value.any?(pattern) : pattern === value
  end

  def month
    Date::MONTHNAMES[release_at.mon]
  end

  def period
    instance_of?(Movie) ? :any : self.class.to_s.gsub(/Movie/, '')
  end

  def self.create(collection, params)
    movie_klass(params[:year]).new(collection, params)
  end

  def self.movie_klass(year)
    MOVIE_PERIODS.find { |k, _v| k === year }&.last || Movie
  end
  private_class_method :movie_klass
end
