require 'date'
require 'csv'
require 'ostruct'
require './movie_collection.rb'
require './movie.rb'

movies = MovieCollection.new

puts '# 5 movies with maximum duration selecting with symbol'
movies.sort_by(:duration).last(5).each { |m| puts m.pretty_print }

puts "\n# 5 movies with maximum duration selecting with ruby block"
movies.sort_by(&:duration).last(5).each { |m| puts m.pretty_print }

puts "\n# 10 comedies (first by release date) selecting with ruby block"
movies.select { |m| m.genre.include?('Comedy') }
      .sort_by(&:release_at)
      .first(10)
      .each { |m| puts m.pretty_print }

puts "\n# Show Comedies named like 'Finding' produced it 2001-2010"
movies.filter(genre: 'Comedy',
              year: (2001..2010),
              title: /Finding/i,
              star_actors: /Albert Brooks/i)
      .each { |m| puts m.pretty_print }

puts "\n# Show films with DiCaprio produced it 2001-2010"
movies.filter(year: (2001..2010), star_actors: /DiCaprio/i).each { |m| puts m.pretty_print }

puts "\n# Show stats for directors"
puts movies.stats(:director)

puts "\n# Show stats for star_actors"
puts movies.stats(:star_actors)

puts "\n# Show stats for months"
puts movies.stats(:month)

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
