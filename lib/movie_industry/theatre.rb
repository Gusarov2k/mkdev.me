module MovieIndustry
  class Theatre
    include Cashbox

    SCHEDULE_RULES = {
      morning: { period: /Ancient/ },
      day: { genre: /Comedy|Adventure/ },
      evening: { genre: /Drama|Horror/ }
    }.freeze

    OPERATING_MODE = {
      4..11 => :morning,
      12..15 => :day,
      16..23 => :evening
    }.freeze

    PRICE = {
      morning: Money.new(300, 'USD'),
      day: Money.new(500, 'USD'),
      evening: Money.new(1000, 'USD')
    }.freeze

    attr_reader :movie_collection

    def initialize(movie_collection)
      @movie_collection = movie_collection
      setup_cashbox
    end

    def show
      puts prepare_movie(Time.now)
    end

    def when?(title)
      movie = movie_collection.filter(title: title).first
      raise "There is no '#{title}' found" unless movie

      %i[morning day evening].detect { |t| check_movie(movie, SCHEDULE_RULES[t]) }
    end

    def buy_ticket(title)
      showing_at = when?(title)
      raise "There is no '#{title}' in actual shedule" unless showing_at

      price = PRICE.fetch(showing_at)
      enroll(price)
      puts "You buy ticket to '#{title}'"
    end

    private

    def prepare_movie(time)
      return 'Sory, Theatre is closed now.' unless operating_mode(time.hour)

      movie = choose_movie(time)
      movie_final_at = (time + movie.duration * 60)
      "Now showing: #{movie} #{time.strftime('%H:%M')}-#{movie_final_at.strftime('%H:%M')}"
    end

    def choose_movie(time)
      filter = SCHEDULE_RULES.fetch(operating_mode(time.hour))
      movie_collection.filter(filter).sample
    end

    def operating_mode(hour)
      OPERATING_MODE.find { |k, _v| k === hour }&.last
    end

    def check_movie(movie, filter)
      filter.all? { |k, v| movie.matches?(k, v) }
    end
  end
end
