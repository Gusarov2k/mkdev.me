module MovieIndustry
  class Theatre
    include Cashbox

    attr_reader :movie_collection, :config

    def initialize(movie_collection = nil, &block)
      @movie_collection = movie_collection || MovieCollection.new('movies.txt')
      @config = ConfigBuilder.new(&block).config
    end

    def show(hall: nil)
      time = Time.now
      @curent_period = config.choose_period(time: time, hall: hall)
      return puts 'Sory, Theatre is closed now.' unless @curent_period

      puts prepare_movie(time)
    end

    def when?(title)
      period = movie_period_by_title(title)
      period&.description
    end

    def buy_ticket(title)
      period = movie_period_by_title(title)
      raise "There is no '#{title}' in actual shedule" unless period

      price = period.price
      puts "You buy ticket to '#{title}'"
      enroll(price)
    end

    def what?(time = Time.now)
      periods = config.select_periods(time: time)
      periods.each { |p| puts p }
    end

    private

    def prepare_movie(time)
      movie = choose_movie
      movie_final_at = (time + movie.duration * 60)
      "Now showing: #{movie} #{time.strftime('%H:%M')}-#{movie_final_at.strftime('%H:%M')}"
    end

    def choose_movie
      movie_collection.filter(@curent_period.filters).sample
    end

    def movie_period_by_title(title)
      movie = movie_collection.filter(title: title).first
      raise "There is no '#{title}' found" unless movie

      config.find_movie_period(movie)
    end
  end
end
