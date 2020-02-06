module MovieIndustry
  class Netflix
    extend Cashbox

    PRICE = {
      AncientMovie => Money.new(100, 'USD'),
      ClassicMovie => Money.new(150, 'USD'),
      ModernMovie => Money.new(300, 'USD'),
      NewMovie => Money.new(500, 'USD')
    }.freeze

    attr_reader :movie_collection

    def initialize(movie_collection, balance = Money.new(0, 'USD'))
      @movie_collection = movie_collection
      Netflix.setup_cashbox if Netflix.cash.nil?
      pay(balance)
    end

    def pay(amount)
      raise 'You can’t reduce balance' if amount.negative?

      Netflix.enroll(amount)
    end

    def how_much?(title)
      movie = movie_collection.filter(title: title).first
      raise "There is no '#{title}' found" unless movie

      PRICE.fetch(movie.class)
    end

    def show(**params)
      time = Time.now
      balance = Netflix.cash
      movie, price, movie_final_at = prepare_movie(time, **params)
      raise "There is not enough money. Your balance $#{balance}" if balance < price

      Netflix.enroll(-price)
      puts "Now showing: #{movie} #{time.strftime('%H:%M')}-#{movie_final_at.strftime('%H:%M')}"
    end

    private

    def prepare_movie(time, **params)
      movie = movie_collection.filter(params).first
      price = how_much?(movie.title)
      movie_final_at = (time + movie.duration * 60)

      [movie, price, movie_final_at]
    end
  end
end
