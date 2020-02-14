require 'date'
require 'csv'
require 'ostruct'
require 'pry'
require 'money'
require 'rubygems'
require 'bundler/setup'
Bundler.require(:default, :test, :development)
require './lib/movie_industry/types.rb'
require './lib/movie_industry/movie.rb'
Dir['./lib/**/*.rb'].sort.each { |file| require file }

file_name = ARGV.first || 'movies.txt'
movies = MovieIndustry::MovieCollection.new(file_name)

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

puts "\n# Let's see to a offline Theatre"
theatre = MovieIndustry::Theatre.new(movies)
puts "\n# By ticket to Terminator"
begin
  theatre.buy_ticket('The Terminator')
rescue StandardError => e
  puts "Got error: #{e.message}"
end

puts "\n# Ooook. How about Godfather?"
theatre.buy_ticket('The Godfather')

puts "\n# And theatre cash now: #{theatre.cash.format}"

puts "\n# Good! Let's see to our Netflix"
netflix1 = MovieIndustry::Netflix.new(movies)

puts "\n# Netflix balanse is #{MovieIndustry::Netflix.cash.format}"

netflix1.pay(Money.new(100_00, 'USD'))
puts "\n# Now Netflix balanse is #{MovieIndustry::Netflix.cash.format}"
puts "\n# But client1 balanse is #{netflix1.client_balance.format}"

netflix2 = MovieIndustry::Netflix.new(movies, Money.new(1000, 'USD'))
puts "\n# Netflix balanse is still #{MovieIndustry::Netflix.cash.format}"

netflix3 = MovieIndustry::Netflix.new(movies, Money.new(1000, 'USD'))
puts "\n# Netflix balanse is still #{MovieIndustry::Netflix.cash.format}"
puts "\n# But client3 balanse is #{netflix3.client_balance.format}"

netflix2.pay(Money.new(10_00, 'USD'))
puts "\n# Now Netflix balanse is #{MovieIndustry::Netflix.cash.format}"
puts "\n# But client2 balanse is #{netflix1.client_balance.format}"

netflix2.show { |movie| movie.genre.include?('Action') && movie.year < 2003 }
netflix2.define_filter(:new_sci_fi) { |movie, year| movie.genre.include?('Action') && movie.year < year }
netflix2.define_filter(:newest_sci_fi, from: :new_sci_fi, arg: 2010)
netflix2.show(newest_sci_fi: true)

netflix2.show(genre: 'Comedy', period: /Ancient/)
netflix3.show(genre: 'Crime', period: /New/)
puts "\n# Now client1: #{netflix1.client_balance.format}"
puts "\n# Now client2: #{netflix2.client_balance.format}"
puts "\n# Now client3: #{netflix3.client_balance.format}"
puts "\n# And finaly Netflix balanse is #{MovieIndustry::Netflix.cash.format}"
