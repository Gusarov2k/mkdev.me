module MovieIndustry
  class ByGenre
    def initialize(movie_collection)
      @movie_collection = movie_collection
      @allowing_methods = movie_collection.existing_genres.map { |g| genre_to_sym(g) }.freeze
    end

    def method_missing(method, *args, &block)
      if @allowing_methods.include?(method)
        @movie_collection.filter(genre: sym_to_filter(method))
      else
        super
      end
    end

    def respond_to_missing?(method, *)
      @allowing_methods.include?(method) || super
    end

    private

    def genre_to_sym(str)
      str.downcase.gsub('-', '_').to_sym
    end

    def sym_to_filter(sym)
      /#{sym.to_s.gsub('_', '-')}/i
    end
  end
end
