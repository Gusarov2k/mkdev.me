class MovieCollection
  attr_reader :file_name

  CSV::Converters[:imdb_list_converter] = lambda { |str, field_info|
    case field_info.header
    when 'year'         then str.to_i
    when 'release_at'   then date_safe_parse(str)
    when 'genre'        then str.split(',')
    when 'duration'     then str.slice(/\d+/).to_i
    when 'star_actors'  then str.split(',')
    else str
    end
  }

  def initialize(file_name = 'movies.txt')
    csv = CSV.read(file_name, col_sep: '|', headers: Movie::HEADERS, converters: :imdb_list_converter)
    @movies = csv.map { |row| Movie.new(row.to_h.merge(movie_collection: self)) }
    @file_name = file_name
  end

  def all
    @movies
  end

  def sort_by(arg = nil, &block)
    return @movies.sort_by(&block) if block_given?

    @movies.sort_by(&arg)
  end

  def select(arg = nil, &block)
    return @movies.select(&block) if block_given?

    key, val = arg.each_pair.first
    @movies.select { |m| m.send(key.to_s).include?(val) }
  end

  def filter(*arg, &block)
    select(*arg, &block)
  end

  def stats(arg)
    key, val = arg.each_pair.first
    count = @movies.select { |m| m.send(key.to_s).include?(val) }.count
    { val => count }
  end

  def existing_genres
    @movies.map(&:genre).flatten.uniq
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
