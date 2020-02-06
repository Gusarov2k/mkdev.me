RSpec.describe MovieIndustry::Cashbox do
  subject { test_object }

  let(:test_object) { Object.new.extend(described_class) }

  describe '#enroll' do
    context 'when positive enroll' do
      subject(:enroll) { test_object.enroll(Money.new(100, 'USD')) }

      it { expect { enroll }.to change(test_object, :cash).by(Money.new(100, 'USD')) }
    end

    context 'when negative enroll' do
      subject(:enroll) { test_object.enroll(Money.new(-100, 'USD')) }

      it { expect { enroll }.to raise_error(RuntimeError, 'You can’t reduce cash') }
    end
  end

  describe '#cash' do
    context 'when new Cashbox' do
      its(:cash) { is_expected.to eq Money.new(0, 'USD') }
    end

    context 'when non zero balance' do
      before { test_object.enroll(Money.new(100, 'USD')) }

      its(:cash) { is_expected.to eq Money.new(100, 'USD') }
    end
  end

  describe '#take' do
    context 'when Bank take money' do
      subject(:take) { test_object.take('Bank') }

      before { test_object.enroll(Money.new(100, 'USD')) }

      it { expect { take }.to change(test_object, :cash).to(Money.new(0, 'USD')) }
    end

    context 'when non Bank take money' do
      subject(:take) { test_object.take('Rogue') }

      it { expect { take }.to raise_error(RuntimeError, 'This is a Robbery!') }
    end
  end
end
