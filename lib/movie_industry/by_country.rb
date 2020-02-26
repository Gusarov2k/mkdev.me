module MovieIndustry
  class ByCountry
    def initialize(movie_collection)
      @movie_collection = movie_collection
      @allowing_methods = movie_collection.map(&:country).uniq.map { |c| country_to_sym(c) }.freeze
    end

    def method_missing(method, *args, &block)
      if @allowing_methods.include?(method)
        @movie_collection.filter(country: sym_to_filter(method))
      else
        super
      end
    end

    def respond_to_missing?(method, *)
      @allowing_methods.include?(method) || super
    end

    private

    def country_to_sym(str)
      str.downcase.gsub(' ', '_').to_sym
    end

    def sym_to_filter(sym)
      /#{sym.to_s.gsub('_', ' ')}/i
    end
  end
end
