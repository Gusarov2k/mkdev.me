module MovieIndustry
  class ClassicMovie < Movie
    def to_s
      movies_count = movie_collection.filter(director: director).count
      "#{title} - classic movie, director #{director} (his #{movies_count} another films)"
    end
  end
end
