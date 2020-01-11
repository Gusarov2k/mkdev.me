class Movie
  attr_accessor(*MovieCollection::HEADERS.map(&:to_sym))

  def initialize(params)
    params.each { |key, value| instance_variable_set("@#{key}", value) }
  end
end
