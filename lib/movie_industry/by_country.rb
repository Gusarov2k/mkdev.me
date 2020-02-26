module MovieIndustry
  class ByCountry
    def initialize(movie_collection)
      @movie_collection = movie_collection
    end

    def method_missing(method, *args, &block)
      return super if prohibited_country_name?(method)
      raise(ArgumentError, "Country filter can't be called with args or block") if block || args.any?

      @movie_collection.filter(country: sym_to_filter(method))
    end

    def respond_to_missing?(method, *)
      !prohibited_country_name?(method) || super
    end

    private

    def prohibited_country_name?(method)
      method.to_s =~ /\?|\!|=/
    end

    def sym_to_filter(sym)
      /#{sym.to_s.gsub('_', ' ')}/i
    end
  end
end
