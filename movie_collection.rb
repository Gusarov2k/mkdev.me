class MovieCollection
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

  def initialize(file_name = 'movies.txt')
    csv = CSV.read(file_name, col_sep: '|', headers: Movie::HEADERS, converters: :imdb_list_converter)
    @movies = csv.map { |row| Movie.new(self, row.to_h) }
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

  def filter(arg)
    arg.each_pair.inject(@movies) { |acc, (key, val)| acc.select { |m| filter_by_type(m, key, val) } }
  end

  def stats(arg)
    case arg
    when :genre       then stats_with_keys_from_array(existing_genres, arg)
    when :star_actors then stats_with_keys_from_array(existing_star_actors, arg)
    when :month       then stats_for_month
    else @movies.group_by { |m| m.send(arg) }.map { |k, v| { k => v.count } }
    end
  end

  def existing_genres
    @existing_genres ||= @movies.map(&:genre).flatten.sort.uniq
  end

  def existing_star_actors
    @existing_star_actors ||= @movies.map(&:star_actors).flatten.uniq.sort_by { |a| a.split.last }
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

  private

  def stats_with_keys_from_array(arr, arg)
    arr.map { |g| { g => @movies.select { |m| m.send(arg).include?(g) }.count } }
  end

  def stats_for_month
    result = []
    months = Date::MONTHNAMES[1..12]
    months.each_with_index do |mon, index|
      count = @movies.select { |m| m.release_at.mon == (index + 1) }.count
      result << { mon => count }
    end
    result
  end

  def filter_by_type(movie, key, val)
    case key
    when :genre       then /#{val}/i === movie.send(key).to_s
    when :star_actors then /#{val}/i === movie.send(key).to_s
    else val === movie.send(key)
    end
  end
end
