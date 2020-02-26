module MovieIndustry
  class ByGenre
    def initialize(movie_collection)
      @movie_collection = movie_collection
      movie_collection.existing_genres.each { |g| create_method(g) }
    end

    private

    def create_method(genre)
      name = genre.downcase.gsub('-', '_').to_sym
      define_singleton_method(name) { @movie_collection.filter(genre: genre) }
    end
  end
end
