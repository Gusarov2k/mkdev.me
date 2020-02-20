module MovieIndustry
  class Theatre
    class Period < DSLThing
      PERIOD_PARAMS = %i[description filters title price hall].freeze

      PERIOD_PARAMS.each { |p| attr_reader p }
      attr_reader :period_start, :period_end

      def initialize(period)
        @period_start, @period_end = period.minmax.map { |e| Time.parse(e) }
      end

      def self.method_missing(meth, *args, &block)
        return super unless PERIOD_PARAMS.include?(meth)

        args = args.first unless meth == :hall
        instance_variable_set("@#{meth}", args)
      end

      def self.respond_to_missing?(method, *)
        PERIOD_PARAMS.include?(method) || super
      end

      def intersect?(period)
        return false unless (hall & period.hall).any?

        time_intersect?(period_start, period_end, period.period_start, period.period_end)
      end

      private

      def time_intersect?(period_1_start, period_1_end, period_2_start, period_2_end)
        return true if (period_1_start..period_1_end).include?(period_2_start)
        return true if (period_1_start..period_1_end).include?(period_2_end)
        return true if (period_2_start..period_2_end).include?(period_1_start)
        return true if (period_2_start..period_2_end).include?(period_1_end)

        false
      end
    end
  end
end
