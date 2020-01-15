FactoryBot.define do
  factory :movie do
    imdb_link   { FFaker::Internet.uri('https') }
    title       { FFaker::Book.title }
    year        { FFaker::Time.date.year }
    country     { FFaker::Address.country }
    release_at  { FFaker::Time.date }
    genre       { Array.new(3) { FFaker::Book.genre } }
    duration    { rand(60..300) }
    rate        { rand(8.0..9.9).round(1).to_s }
    director    { FFaker::Name.name }
    star_actors { Array.new(5) { FFaker::Name.name } }
  end
end
