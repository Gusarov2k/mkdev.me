module MovieIndustry
  class AncientMovie < MovieIndustry::Movie
    def to_s
      "#{title} - old movie (#{year} year)"
    end
  end
end
