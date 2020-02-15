module MovieIndustry
  class MovieCollection
    include Enumerable
    attr_reader :file_name

    def initialize(file_name)
      csv = CSV.read(file_name, col_sep: '|', headers: Movie.attributes.keys)
      @movies = csv.map { |row| Movie.create(self, row.to_h) }
      @file_name = file_name
    end

    def all
      @movies
    end

    def each(&block)
      @movies.each(&block)
    end

    def sort_by(arg = nil, &block)
      return super(&block) if block_given?

      super(&arg)
    end

    def select(arg = nil, &block)
      return super(&block) if block_given?

      key, val = arg.first
      @movies.select { |m| m.send(key.to_s).include?(val) }
    end

    def filter(arg = nil, &block)
      return @movies.select(&block) if block_given?

      arg.inject(@movies) { |acc, (key, val)| acc.select { |m| m.matches?(key, val) } }
    end

    def stats(arg)
      @movies.flat_map(&arg).group_by(&:itself).to_h { |k, v| [k, v.count] }
    end

    def existing_genres
      @existing_genres ||= @movies.flat_map(&:genre).sort.uniq
    end
  end
end
