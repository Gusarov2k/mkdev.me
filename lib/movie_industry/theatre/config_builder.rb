module MovieIndustry
  class Theatre
    class ConfigBuilder
      attr_reader :config

      def initialize(&block)
        @config = Config.new
        rules = block_given? ? block : DefaultRules.call
        instance_eval(&rules)
      end

      def hall(name, **params)
        h = Hall.new(name, **params)
        @config.halls[name] = h
      end

      def period(period, &block)
        p = Period.new(period, &block)

        @config.periods.values.each do |i|
          raise "Period '#{i.description}' conflicts with '#{p.description}'" if i.intersect?(p)
        end

        @config.periods[period] = p
      end
    end
  end
end
