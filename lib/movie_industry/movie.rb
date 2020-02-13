module MovieIndustry
  class Movie
    require_relative 'ancient_movie'
    require_relative 'classic_movie'
    require_relative 'modern_movie'
    require_relative 'new_movie'

    HEADERS = %i[imdb_link title year country release_at genre duration rate director star_actors].freeze
    MOVIE_PERIODS = {
      1900..1945 => :ancient,
      1945..1968 => :classic,
      1968..2000 => :modern,
      2000.. => :new
    }.freeze

    MOVIE_CLASSES = {
      ancient: MovieIndustry::AncientMovie,
      classic: MovieIndustry::ClassicMovie,
      modern: MovieIndustry::ModernMovie,
      new: MovieIndustry::NewMovie
    }.freeze

    PERIOD_KEY = {
      /Ancient/ => :ancient,
      /Classic/ => :classic,
      /Modern/ => :modern,
      /New/ => :new
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
      instance_of?(Movie) ? :any : self.class.to_s.gsub(/MovieIndustry::/, '').gsub(/Movie/, '').downcase.to_sym
    end

    def self.create(collection, params)
      movie_klass(params[:year]).new(collection, params)
    end

    def self.convert_periods(params)
      params[:period] = PERIOD_KEY.fetch(params[:period]) if params.key?(:period)
      params # TODO: find some nice method 4 update hash
    end

    def self.movie_klass(year)
      MOVIE_CLASSES[MOVIE_PERIODS.find { |k, _v| k === year }&.last] || Movie
    end
    private_class_method :movie_klass
  end
end
