class Movie
  HEADERS = %w[imdb_link title year country release_at genre duration rate director star_actors].freeze
  attr_accessor(*HEADERS.map(&:to_sym))
  attr_reader :movie_collection

  def initialize(params)
    params.each { |key, value| instance_variable_set("@#{key}", value) }
  end

  def pretty_print
    puts "#{title} (#{release_at}; #{genre.join('/')}) - #{duration} min"
  end

  def to_s
    pretty_print
  end

  def has_genre?(attr)
    err_msg = "There is no genre #{attr} in #{movie_collection.file_name}"
    raise err_msg unless movie_collection.existing_genres.include?(attr)

    genre.include?(attr)
  end
end
