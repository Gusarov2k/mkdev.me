module MovieIndustry
  class ModernMovie < Movie
    def to_s
      "#{title} - modern movie: stars #{star_actors.join(', ')}"
    end
  end
end
