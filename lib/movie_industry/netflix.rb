module MovieIndustry
  class Netflix
    extend Cashbox

    PRICE = {
      AncientMovie => Money.new(100, 'USD'),
      ClassicMovie => Money.new(150, 'USD'),
      ModernMovie => Money.new(300, 'USD'),
      NewMovie => Money.new(500, 'USD')
    }.freeze

    attr_reader :movie_collection, :client_balance

    def initialize(movie_collection, client_balance = Money.new(0, 'USD'))
      @movie_collection = movie_collection
      @client_balance = client_balance
      @user_filters = {}
    end

    def pay(amount)
      raise 'You can’t reduce balance' if amount.negative?

      @client_balance += amount
    end

    def how_much?(title)
      movie = movie_collection.filter(title: title).first
      raise "There is no '#{title}' found" unless movie

      PRICE.fetch(movie.class)
    end

    def show(**params, &block)
      time = Time.now
      movie, price, movie_final_at = prepare_movie(time, **params, &block)
      raise "There is not enough money. Your balance $#{@client_balance}" if @client_balance < price

      puts "Now showing: #{movie} #{time.strftime('%H:%M')}-#{movie_final_at.strftime('%H:%M')}"
      self.class.enroll(price)
      @client_balance -= price
    end

    def define_filter(name, from: nil, arg: nil, &block)
      code = from ? @user_filters.fetch(from) : block
      @user_filters[name] = arg ? proc { |m| code.call(m, arg) } : code
    end

    private

    def prepare_movie(time, **params, &block)
      movie = select_movie(**params, &block)
      price = how_much?(movie.title)
      movie_final_at = (time + movie.duration * 60)

      [movie, price, movie_final_at]
    end

    def select_movie(**params, &block)
      user_filters, standart_filter = params.each_pair.partition { |k, _v| @user_filters[k] }.map(&:to_h)
      movies = movie_collection.filter(standart_filter)
      movies = movies.filter(&block) if block_given?
      user_filters.each_pair.inject(movies) { |acc, (k, v)| acc.filter { |m| @user_filters[k].call(m, v) } }.first
    end
  end
end
