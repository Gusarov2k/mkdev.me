module MovieIndustry
  class MovieCollection
    include Enumerable
    attr_reader :file_name

    CSV::Converters[:imdb_list_converter] = lambda { |str, field_info|
      case field_info.header
      when :year         then str.to_i
      when :release_at   then date_safe_parse(str)
      when :genre        then str.split(',')
      when :duration     then str.slice(/\d+/).to_i
      when :star_actors  then str.split(',')
      else str
      end
    }

    def initialize(file_name)
      csv = CSV.read(file_name, col_sep: '|', headers: Movie.attributes.keys, converters: :imdb_list_converter)
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

    def self.date_safe_parse(str)
      patern = case str
               when /\d{4}-\d{2}-\d{2}/ then '%Y-%m-%d'
               when /\d{4}-\d{2}/       then '%Y-%m'
               else                          '%Y'
               end
      Date.strptime(str, patern)
    end
    private_class_method :date_safe_parse
  end
end
