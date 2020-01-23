class Theatre
  attr_reader :movie_collection

  def initialize(movie_collection)
    @movie_collection = movie_collection
  end

  def show
    time = Time.now
    movie = movie_schedule(time)
    movie_final_at = (time + movie.duration * 60)
    puts "Now showing: #{movie} #{time.strftime('%H:%M')}-#{movie_final_at.strftime('%H:%M')}"
  end

  def when?(title)
    movie = movie_collection.filter(title: title).first
    raise "There is no '#{title}' found" unless movie

    return :morning if morning?(movie)
    return :day     if day?(movie)
    return :evening if evening?(movie)

    :never
  end

  private

  def movie_schedule(time)
    case time.hour
    when (4..11)  then movie_collection.select { |m| morning?(m) }.first
    when (12..15) then movie_collection.select { |m| day?(m) }.first
    else movie_collection.select { |m| evening?(m) }.first
    end
  end

  def morning?(movie)
    movie.is_a?(AncientMovie)
  end

  def day?(movie)
    movie.has_genre?('Comedy') || movie.has_genre?('Adventure')
  end

  def evening?(movie)
    movie.has_genre?('Drama') || movie.has_genre?('Horror')
  end
end
