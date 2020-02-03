class Netflix
  PRICE = {
    AncientMovie => 1,
    ClassicMovie => 1.5,
    ModernMovie => 3,
    NewMovie => 5
  }.freeze

  attr_reader :movie_collection, :balance

  def initialize(movie_collection, balance = 0)
    @movie_collection = movie_collection
    @balance = balance
  end

  def pay(amount)
    raise 'You can’t reduce balance' if amount.negative?

    @balance += amount
  end

  def how_much?(title)
    movie = movie_collection.filter(title: title).first
    raise "There is no '#{title}' found" unless movie

    PRICE.fetch(movie.class)
  end

  def show(**params)
    movie = movie_collection.filter(params).first
    price = how_much?(movie.title)
    raise "There is not enough money. Your balance $#{@balance}" if @balance < price

    @balance -= price
    time = Time.now
    movie_final_at = (time + movie.duration * 60)
    puts "Now showing: #{movie} #{time.strftime('%H:%M')}-#{movie_final_at.strftime('%H:%M')}"
  end
end
