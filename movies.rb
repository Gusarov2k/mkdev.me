require 'date'
require 'csv'
require 'ostruct'

file_name = ARGV.first || 'movies.txt'
headers = %w[imdb_link title year country release_at genres duration rate director star_actors]

def date_safe_parse(str)
  patern = case str
           when /\d{4}-\d{2}-\d{2}/ then '%Y-%m-%d'
           when /\d{4}-\d{2}/       then '%Y-%m'
           else                          '%Y'
           end
  Date.strptime(str, patern)
end

CSV::Converters[:imdb_list_converter] = lambda { |str, field_info|
  case field_info.header
  when 'year'       then str.to_i
  when 'country'    then str.split(',')
  when 'release_at' then date_safe_parse(str)
  when 'genres'     then str.split(',')
  when 'duration'   then str.slice(/\d+/).to_i
  else str
  end
}

csv = CSV.read(file_name, col_sep: '|', headers: headers, converters: :imdb_list_converter)
movies = csv.map { |row| OpenStruct.new(row.to_h) }

def movie_format(movie)
  "#{movie.title} (#{movie.release_at}; #{movie.genres.join('/')}) - #{movie.duration} min"
end

puts '# 5 movies with maximum duration:'
movies.sort_by(&:duration).last(5).each { |m| puts movie_format(m) }

puts "\n# 10 comedies (first by release date)"
movies.select { |m| m.genres.include?('Comedy') }
      .sort_by(&:release_at)
      .first(10)
      .each { |m| puts movie_format(m) }

puts "\n# List of all directors alphabetically (no repetition!)"
puts(movies.map(&:director).uniq.sort_by { |e| e.split.last })

puts "\n# Number of films shot not in the USA"
puts movies.reject { |m| m.country.include?('USA') }.count

puts "\n# Movies count by month"
movies.group_by { |m| m.release_at.mon }.sort.each { |k, v| puts "#{Date::MONTHNAMES[k]}: #{v.count}" }
