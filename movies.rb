GOOD_MOVIES = ['Matrix'].freeze

movie = ARGV.first
puts GOOD_MOVIES.include?(movie) ? "#{movie} is a good movie" : "#{movie} is a bad movie"
