module MovieIndustry
  class Theatre
    class ConfigBuilder
      DEFAULT_RULES = proc do
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
      end.freeze

      Hall = Struct.new(:code, :title, :places, keyword_init: true)

      attr_reader :config

      def initialize(&block)
        @config = Config.new
        rules = block_given? ? block : DEFAULT_RULES
        instance_eval(&rules)
      end

      def hall(name, **params)
        h = Hall.new(code: name, **params)
        @config.halls[name] = h
      end

      def period(key, &block)
        p = Period.new(key, &block)
        raise "Period '#{p.description}' has unregistred hall" if hall_valid?(p.hall)

        @config.periods.each do |i|
          raise "Period '#{i.description}' conflicts with '#{p.description}'" if i.intersect?(p)
        end

        @config.periods << p
      end

      private

      def hall_valid?(hall)
        (hall - config.existing_halls).any?
      end
    end
  end
end
