class Theatre
  SCHEDULE_RULES = {
    morning: { period: /Ancient/ },
    day: { genre: /Comedy|Adventure/ },
    evening: { genre: /Drama|Horror/ }
  }.freeze

  TIMES_OF_DAY = {
    4..11 => :morning,
    12..15 => :day,
    16..23 => :evening
  }.freeze

  attr_reader :movie_collection

  def initialize(movie_collection)
    @movie_collection = movie_collection
  end

  def show
    puts prepare_movie(Time.now)
  end

  def when?(title)
    movie = movie_collection.filter(title: title).first
    raise "There is no '#{title}' found" unless movie

    %i[morning day evening].detect { |t| check_movie(movie, SCHEDULE_RULES[t]) }
  end

  private

  def prepare_movie(time)
    return 'Sory, Theatre is closed now.' unless times_of_day(time.hour)

    movie = choose_movie(time)
    movie_final_at = (time + movie.duration * 60)
    "Now showing: #{movie} #{time.strftime('%H:%M')}-#{movie_final_at.strftime('%H:%M')}"
  end

  def choose_movie(time)
    filter = SCHEDULE_RULES[times_of_day(time.hour)]
    movie_collection.filter(filter).first
  end

  def times_of_day(hour)
    TIMES_OF_DAY.find { |k, _v| k === hour }&.last
  end

  def check_movie(movie, filter)
    filter.each_pair.inject([movie]) { |acc, (key, val)| acc.select { |m| m.matches?(key, val) } }.any?
  end
end
