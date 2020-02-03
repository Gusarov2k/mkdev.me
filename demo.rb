require 'date'
require 'csv'
require 'ostruct'
require 'pry'
require './lib/movie.rb'
Dir['./lib/*_movie.rb'].sort.each { |file| require file }
Dir['./lib/*.rb'].sort.each { |file| require file }
# m = AncientMovie.new('', year: 1930)

# binding.pry
file_name = ARGV.first || 'movies.txt'
movies = MovieCollection.new(file_name)

puts '# 5 movies with maximum duration selecting with symbol'
puts movies.sort_by(:duration).last(5)

puts "\n# 5 movies with maximum duration selecting with ruby block"
puts movies.sort_by(&:duration).last(5)

puts "\n# 10 comedies (first by release date) selecting with ruby block"
puts movies.select { |m| m.genre.include?('Comedy') }
           .sort_by(&:release_at)
           .first(10)

puts "\n# Show Comedies named like 'Finding' produced it 2001-2010"
puts movies.filter(genre: 'Comedy',
                   year: (2001..2010),
                   title: /Finding/i,
                   star_actors: /Albert Brooks/i)

puts "\n# Show films with DiCaprio produced it 2001-2010"
puts movies.filter(year: (2001..2010), star_actors: /DiCaprio/i)

puts "\n# Show stats for first 5 directors"
puts movies.stats(:director).first(5)

puts "\n# Show stats for first 5 star_actors"
puts movies.stats(:star_actors).first(5)

puts "\n# Show stats for months"
puts movies.stats(:month)

puts "\n# Show stats for genres"
puts movies.stats(:genre)

puts "\n# Show star actors for 1th movie in the list"
puts movies.all.first.star_actors

puts "\n# Is first movie a Comedy?"
puts movies.all.first.has_genre?('Comedy')

puts "\n# Is first movie a Tragedy?"
begin
  puts movies.all.first.has_genre?('Tragedy')
rescue StandardError => e
  puts "Got error: #{e.message}"
end
