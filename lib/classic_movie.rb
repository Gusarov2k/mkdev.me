class ClassicMovie < Movie
  def to_s
    "#{title} - classic movie, director #{director} (his 10 another films)"
  end
end
