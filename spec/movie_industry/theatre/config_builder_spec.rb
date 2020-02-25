RSpec.describe MovieIndustry::Theatre::ConfigBuilder do
  describe '.new' do
    context 'when DSL-config has periods conflict' do
      let(:config_1) do
        proc do
          hall :red, title: 'Красный зал', places: 100
          hall :blue, title: 'Синий зал', places: 50

          period '09:00'..'11:00' do
            description 'Утренний сеанс'
            filters genre: 'Comedy', year: 1900..1980
            price 10
            hall :red, :blue
          end

          period '10:00'..'16:00' do
            description 'Спецпоказ'
            title 'The Terminator'
            price 50
            hall :red
          end
        end
      end

      let(:config_2) do
        proc do
          hall :red, title: 'Красный зал', places: 100
          hall :blue, title: 'Синий зал', places: 50

          period '09:00'..'11:00' do
            description 'Утренний сеанс'
            filters genre: 'Comedy', year: 1900..1980
            price 10
            hall :red, :blue
          end

          period '08:00'..'16:00' do
            description 'Утренник'
            title 'The Terminator'
            price 50
            hall :red
          end
        end
      end

      it { expect { described_class.new(&config_1) }.to raise_error(RuntimeError, "Period 'Утренний сеанс' conflicts with 'Спецпоказ'") }
      it { expect { described_class.new(&config_2) }.to raise_error(RuntimeError, "Period 'Утренний сеанс' conflicts with 'Утренник'") }
    end
  end
end
