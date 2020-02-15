module MovieIndustry
  class Movie
    extend Dry::Initializer
    require_relative 'ancient_movie'
    require_relative 'classic_movie'
    require_relative 'modern_movie'
    require_relative 'new_movie'

    MOVIE_PERIODS = {
      1900..1945 => :ancient,
      1945..1968 => :classic,
      1968..2000 => :modern,
      2000.. => :new
    }.freeze

    MOVIE_CLASSES = {
      ancient: AncientMovie,
      classic: ClassicMovie,
      modern: ModernMovie,
      new: NewMovie
    }.freeze

    option :imdb_link, Types::Coercible::String, optional: true, dafault: proc { nil }
    option :title, Types::Coercible::String, optional: true, dafault: proc { nil }
    option :year, Types::Coercible::Integer, optional: true, dafault: proc { nil }
    option :country, Types::Coercible::String, optional: true, dafault: proc { nil }
    option :release_at, Types::Params::Date, optional: true, dafault: proc { nil }
    option :genre, Types::Array.of(Types::Coercible::String), optional: true, dafault: proc { nil }
    option :duration, Types::Coercible::Integer, optional: true, dafault: proc { nil }
    option :rate, Types::Coercible::String, optional: true, dafault: proc { nil }
    option :director, Types::Coercible::String, optional: true, dafault: proc { nil }
    option :star_actors, Types::Array.of(Types::Coercible::String), optional: true, dafault: proc { nil }
    attr_reader :movie_collection

    def initialize(movie_collection, **data)
      super(**data)
      @movie_collection = movie_collection
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

    def self.attributes
      dry_initializer.definitions
    end

    def self.movie_klass(year)
      MOVIE_CLASSES[MOVIE_PERIODS.find { |k, _v| k === year }&.last] || Movie
    end
    private_class_method :movie_klass
  end
end
