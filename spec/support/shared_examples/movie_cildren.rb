RSpec.shared_examples 'Movie children' do
  subject { described_class.new(movie_collection, params) }

  let(:movie_collection) { double }
  let(:params) { {} }

  it { is_expected.to be_act_like_a_movie }
end
