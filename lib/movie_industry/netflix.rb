module MovieIndustry
  class Netflix
    extend Cashbox

    PRICE = {
      ancient: Money.new(100, 'USD'),
      classic: Money.new(150, 'USD'),
      modern: Money.new(300, 'USD'),
      new: Money.new(500, 'USD')
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

      PRICE.fetch(movie.period)
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
      raise 'Wrong filter setup!' unless from || block_given?
      raise "From and block can't work together!" if from && block_given?

      return @user_filters[name] = block if block_given?

      parent_filter = @user_filters.fetch(from)
      @user_filters[name] = proc { |m| parent_filter.call(m, arg) }
    end

    private

    def prepare_movie(time, **params, &block)
      movie = filter(**params, &block).first
      price = how_much?(movie.title)
      movie_final_at = (time + movie.duration * 60)

      [movie, price, movie_final_at]
    end

    def filter(**params, &block)
      user_filters, standart_filter = params.partition { |k, _v| @user_filters.key?(k) }.map(&:to_h)
      movies = movie_collection.filter(standart_filter)
      movies = movies.filter(&block) if block_given?
      user_filters.inject(movies) { |acc, (k, v)| acc.select { |m| @user_filters[k].call(m, v) } }
    end
  end
end
