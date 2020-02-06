module MovieIndustry
  class ModernMovie < MovieIndustry::Movie
    def to_s
      "#{title} - modern movie: stars #{star_actors.join(', ')}"
    end
  end
end
