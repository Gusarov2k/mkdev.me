module MovieIndustry
  class Theatre
    include Cashbox

    SCHEDULE_RULES = {
      morning: { period: :ancient },
      day: { genre: /Comedy|Adventure/ },
      evening: { genre: /Drama|Horror/ },
      # TODO: Возможно тут proc, еще подумаю
      dsl: :dsl
    }.freeze

    OPERATING_MODE = {
      4..11 => :morning,
      12..15 => :day,
      16..23 => :evening
    }.freeze

    PRICE = {
      morning: Money.new(300, 'USD'),
      day: Money.new(500, 'USD'),
      evening: Money.new(1000, 'USD'),
      # TODO: Возможно тут proc, еще подумаю
      dsl: :dsl
    }.freeze

    attr_reader :movie_collection, :halls, :periods

    def initialize(movie_collection)
      @movie_collection = movie_collection
    end

    def self.new(movie_collection = MovieIndustry::MovieCollection.new('movies.txt'), &block)
      instance = super
      instance.class.instance_eval(&block) if block_given?
      instance_variables.each do |var|
        instance.instance_variable_set(var, instance_variable_get(var))
      end
      instance
    end

    def self.hall(name, **params)
      @halls ||= {}
      h = Hall.new(name, **params)
      @halls[name] = h
    end

    def self.period(period, &block)
      @periods ||= {}
      p = Period.new(period)
      p.class.class_eval(&block) if block_given?
      p.copyvars
      @periods.values.each do |i|
        raise "Period '#{i.description}' conflicts with '#{p.description}'" if i.intersect?(p)
      end

      @periods[period] = p
    end

    def show
      puts prepare_movie(Time.now)
    end

    def when?(title)
      # TODO: научить искать по DSL-конфигу
      return :ask_dsl if dsl_config?

      movie = movie_collection.filter(title: title).first
      raise "There is no '#{title}' found" unless movie

      %i[morning day evening].detect { |t| check_movie(movie, SCHEDULE_RULES[t]) }
    end

    def buy_ticket(title)
      showing_at = when?(title)
      raise "There is no '#{title}' in actual shedule" unless showing_at

      # binding.pry
      # TODO: научить искать по DSL-конфигу
      price = PRICE.fetch(showing_at)
      puts "You buy ticket to '#{title}'"
      enroll(price)
    end

    private

    def prepare_movie(time)
      return 'Sory, Theatre is closed now.' unless operating_mode(time)

      movie = choose_movie(time)
      movie_final_at = (time + movie.duration * 60)
      "Now showing: #{movie} #{time.strftime('%H:%M')}-#{movie_final_at.strftime('%H:%M')}"
    end

    def choose_movie(time)
      filter = SCHEDULE_RULES.fetch(operating_mode(time))
      filter = prepare_dsl_filter(time) if filter == :dsl
      # binding.pry
      movie_collection.filter(filter).sample
    end

    def operating_mode(time)
      return OPERATING_MODE.find { |k, _v| k === time.hour }&.last unless dsl_config?

      periods.values.select { |p| p.include?(time) }.any? ? :dsl : false
    end

    def check_movie(movie, filter)
      filter.all? { |k, v| movie.matches?(k, v) }
    end

    def dsl_config?
      @halls&.any? && @periods&.any?
    end

    def prepare_dsl_filter(time)
      period = periods.values.select { |p| p.include?(time) }.sample
      if period.title
        { title: period.title }
      elsif period.filters
        period.filters
      else
        raise 'Cant filter'
      end
    end
  end
end
