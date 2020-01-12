require 'date'
require 'csv'
require 'ostruct'
require './movie_collection.rb'
require './movie.rb'

movies = MovieCollection.new

puts '# 5 movies with maximum duration selecting with symbol'
movies.sort_by(:duration).last(5).each(&:pretty_print)

puts "\n# 5 movies with maximum duration selecting with ruby block"
movies.sort_by(&:duration).last(5).each(&:pretty_print)

puts "\n# 10 comedies (first by release date) selecting with ruby block"
movies.select { |m| m.genre.include?('Comedy') }
      .sort_by(&:release_at)
      .first(10)
      .each(&:pretty_print)

puts "\n# 10 comedies (first by release date) selecting with hash"
movies.filter(genre: 'Comedy')
      .sort_by(&:release_at)
      .first(10)
      .each(&:pretty_print)

puts "\n# Show stats for director Quentin Tarantino"
puts movies.stats(director: 'Quentin Tarantino')

puts "\n# Show stats for star_actor Henry Fonda"
puts movies.stats(star_actors: 'Henry Fonda')

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
