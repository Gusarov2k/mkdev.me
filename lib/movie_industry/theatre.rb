module MovieIndustry
  class Theatre
    include Cashbox

    SCHEDULE_RULES = {
      morning: { period: :ancient },
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

    attr_reader :movie_collection, :config

    def initialize(movie_collection = nil, &block)
      @movie_collection = movie_collection || MovieCollection.new('movies.txt')
      @config = ConfigBuilder.new(&block).config if block_given?
    end

    def show
      time = Time.now
      @curent_period = config.period_by_time(time)
      # puts "curent_period: #{@curent_period}"
      return 'Sory, Theatre is closed now.' unless @curent_period

      puts prepare_movie(time)
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
      puts "You buy ticket to '#{title}'"
      enroll(price)
    end

    private

    def prepare_movie(time)
      movie = choose_movie # (time)
      movie_final_at = (time + movie.duration * 60)
      "Now showing: #{movie} #{time.strftime('%H:%M')}-#{movie_final_at.strftime('%H:%M')}"
    end

    def choose_movie # (_time)
      # filter = SCHEDULE_RULES.fetch(operating_mode(time))
      filter = if @curent_period.title
                 { title: @curent_period.title }
               elsif @curent_period.filters
                 @curent_period.filters
               else
                 {}
               end
      movie_collection.filter(filter).sample
    end

    # def operating_mode(time)
    #   # OPERATING_MODE.find { |k, _v| k === time.hour }&.last
    #   binding.pry
    # end

    def check_movie(movie, filter)
      filter.all? { |k, v| movie.matches?(k, v) }
    end
  end
end
