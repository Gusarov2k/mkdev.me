module MovieIndustry
  class NewMovie < Movie
    def to_s
      "#{title} - new movie, released #{Date.today.year - year} years ago!"
    end
  end
end
