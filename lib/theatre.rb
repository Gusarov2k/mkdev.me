class Theatre
  SCHEDULE_RULES = {
    morning: OpenStruct.new(key: :class, value: [AncientMovie]),
    day: OpenStruct.new(key: :genre, value: %w[Comedy Adventure]),
    evening: OpenStruct.new(key: :genre, value: %w[Drama Horror])
  }.freeze

  TIMES_OF_DAY = {
    4..11 => :morning,
    12..15 => :day
  }.freeze

  attr_reader :movie_collection

  def initialize(movie_collection)
    @movie_collection = movie_collection
  end

  def show
    time = Time.now
    movie = movie_schedule(time)
    movie_final_at = (time + movie.duration * 60)
    puts "Now showing: #{movie} #{time.strftime('%H:%M')}-#{movie_final_at.strftime('%H:%M')}"
  end

  def when?(title)
    movie = movie_collection.filter(title: title).first
    raise "There is no '#{title}' found" unless movie

    %i[morning day evening].select { |t| check_movie(movie, SCHEDULE_RULES[t]) }.first || :never
  end

  private

  def movie_schedule(time)
    filter = SCHEDULE_RULES[times_of_day(time.hour)]
    movie_collection.select { |m| check_movie(m, filter) }.first
  end

  def times_of_day(hour)
    TIMES_OF_DAY.find { |k, _v| k === hour }&.last || :evening
  end

  def check_movie(movie, filter)
    ([movie.send(filter.key)].flatten & filter.value).any?
  end
end
