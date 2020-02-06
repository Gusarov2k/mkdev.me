module MovieIndustry
  class AncientMovie < Movie
    def to_s
      "#{title} - old movie (#{year} year)"
    end
  end
end
