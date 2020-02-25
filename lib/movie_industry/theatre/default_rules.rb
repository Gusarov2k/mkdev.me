module MovieIndustry
  class Theatre
    module DefaultRules
      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      def self.call
        proc do
          hall :default, title: 'Default', places: 1000

          period '04:00'..'11:00' do
            description 'Morning'
            filters period: :ancient
            price 3
            hall :default
          end

          period '12:00'..'15:00' do
            description 'Day'
            filters genre: /Comedy|Adventure/
            price 5
            hall :default
          end

          period '16:00'..'23:00' do
            description 'Evening'
            filters genre: /Drama|Horror/
            price 10
            hall :default
          end
        end
      end
      # rubocop:enable all
    end
  end
end
