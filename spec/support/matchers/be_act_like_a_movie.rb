RSpec::Matchers.define :be_act_like_a_movie do
  match do |actual|
    expect(actual).to be_an(Movie)
  end
end
