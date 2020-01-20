RSpec::Matchers.define :be_a_array_of do |instance_class|
  match do |actual|
    expect(actual).to be_an(Array).and all be_an(instance_class)
  end
end
