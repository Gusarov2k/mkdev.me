class FooClass
  include MovieIndustry::Cashbox
end

RSpec.describe MovieIndustry::Cashbox do
  subject { instance }

  let(:instance) { FooClass.new }

  before { instance.setup_cashbox }

  describe '#setup_cashbox' do
    it { expect(FooClass.new.setup_cashbox).to eq(Money.new(0, 'USD')) }
  end

  describe '#enroll' do
    context 'when positive enroll' do
      subject(:enroll) { instance.enroll(Money.new(100, 'USD')) }

      it { expect { enroll }.to change(instance, :cash).by(Money.new(100, 'USD')) }
    end

    context 'when negative enroll' do
      subject(:enroll) { instance.enroll(Money.new(-100, 'USD')) }

      it { expect { enroll }.to change(instance, :cash).by(Money.new(-100, 'USD')) }
    end
  end

  describe '#cash' do
    context 'when zero balance' do
      its(:cash) { is_expected.to eq Money.new(0, 'USD') }
    end

    context 'when non zero balance' do
      before { instance.enroll(Money.new(100, 'USD')) }

      its(:cash) { is_expected.to eq Money.new(100, 'USD') }
    end
  end

  describe '#take' do
    context 'when Bank take money' do
      subject(:take) { instance.take('Bank') }

      before { instance.enroll(Money.new(100, 'USD')) }

      it { expect { take }.to change(instance, :cash).to(Money.new(0, 'USD')) }
    end

    context 'when non Bank take money' do
      subject(:take) { instance.take('Rogue') }

      it { expect { take }.to raise_error(RuntimeError, 'This is a Robbery!') }
    end
  end
end