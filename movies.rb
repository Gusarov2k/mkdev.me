require 'date'

file_name = ARGV.first || 'movies.txt'
file = File.open file_name

def date_safe_parse(str)
  patern = case str
           when /\d{4}-\d{2}-\d{2}/ then '%Y-%m-%d'
           when /\d{4}-\d{2}/       then '%Y-%m'
           else                          '%Y'
           end
  Date.strptime(str, patern)
end

movies = file.map do |line|
  arr = line.split('|')
  {
    imdb_link: arr[0],
    title: arr[1],
    year: arr[2].to_i,
    country: arr[3].split(','),
    release_at: date_safe_parse(arr[4]),
    genres: arr[5].split(','),
    duration: arr[6].slice(/\d+/).to_i,
    rate: arr[7],
    director: arr[8],
    star_actors: arr[9].split(',')
  }
end

def movie_format(obj)
  "#{obj[:title]} (#{obj[:release_at]}; #{obj[:genres].join('/')}) - #{obj[:duration]} min"
end

puts '# 5 movies with maximum duration:'
movies.sort_by { |i| i[:duration] }.last(5).map { |m| puts movie_format(m) }

puts "\n# 10 comedies (first by release date)"
movies.select { |m| m[:genres].include?('Comedy') }
      .sort_by { |i| i[:release_at] }
      .first(10)
      .map { |m| puts movie_format(m) }

puts "\n# List of all directors alphabetically (no repetition!)"
puts(movies.map { |m| m[:director] }.uniq.sort_by { |e| e.split.last })

puts "\n# Number of films shot not in the USA"
puts movies.reject { |m| m[:country].include?('USA') }.count
