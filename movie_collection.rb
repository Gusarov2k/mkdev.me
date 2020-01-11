class MovieCollection
  HEADERS = %w[imdb_link title year country release_at genres duration rate director star_actors].freeze
  CSV::Converters[:imdb_list_converter] = lambda { |str, field_info|
    case field_info.header
    when 'year'         then str.to_i
    when 'country'      then str.split(',')
    when 'release_at'   then date_safe_parse(str)
    when 'genres'       then str.split(',')
    when 'duration'     then str.slice(/\d+/).to_i
    when 'star_actors'  then str.split(',')
    else str
    end
  }

  def initialize(file_name = 'movies.txt')
    csv = CSV.read(file_name, col_sep: '|', headers: HEADERS, converters: :imdb_list_converter)
    @movies = csv.map { |row| Movie.new(row.to_h) }
  end

  def all
    @movies
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
