module MovieIndustry
  class Netflix
    extend Cashbox
    include Cashbox::SetupMoney

    PRICE = {
      AncientMovie => Money.new(100, 'USD'),
      ClassicMovie => Money.new(150, 'USD'),
      ModernMovie => Money.new(300, 'USD'),
      NewMovie => Money.new(500, 'USD')
    }.freeze

    attr_reader :movie_collection, :client_balance

    def initialize(movie_collection, client_balance = Money.new(0, 'USD'))
      @movie_collection = movie_collection
      @client_balance = setup_money + client_balance
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
      filter, arg = prepare_filter(params, &block)
      movie = movie_collection.filter(filter, arg).first
      price = how_much?(movie.title)
      movie_final_at = (time + movie.duration * 60)

      [movie, price, movie_final_at]
    end

    def prepare_filter(params, &block)
      key, arg = params.each_pair.first
      filter = @user_filters[key]
      return filter, arg if filter && arg

      block_given? ? block : params
    end
  end
end
