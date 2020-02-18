module MovieIndustry
  class MovieArray
    include Enumerable

    def initialize(movies, genres)
      @movies = movies
      @genres = genres
      self.class.create_methods(@genres)
    end

    def each(&block)
      @movies.each(&block)
    end

    def method_missing(meth, *args, &block)
      movies = select { |movie| /#{meth}/i === movie.country }
      movies.any? ? movies : super
    end

    def respond_to_missing?(method, *)
      @countrys ||= @movies.map { |m| m.country.downcase.gsub(/(-)|( )/, '_') }.uniq.map(&:to_sym)
      @countrys.include?(method) || super
    end

    def self.create_methods(names)
      names.each do |name|
        define_method name.downcase.gsub(/(-)|( )/, '_') do
          select { |m| m.genre.include?(name) }
        end
      end
    end
  end
end
