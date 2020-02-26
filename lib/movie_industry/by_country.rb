module MovieIndustry
  class ByCountry
    def initialize(movie_collection)
      @movie_collection = movie_collection
    end

    def method_missing(method, *args, &block)
      movies = filter_by_country(method)
      return movies if movies.any?

      super
    end

    def respond_to_missing?(method, *)
      filter_by_country(method).any? || super
    end

    private

    def filter_by_country(sym)
      @movie_collection.filter(country: sym_to_filter(sym))
    end

    def sym_to_filter(sym)
      /#{sym.to_s.gsub('_', ' ')}/i
    end
  end
end
