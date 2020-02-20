module MovieIndustry
  class Theatre
    class Period < DSLThing
      PERIOD_PARAMS = %i[description filters title price hall].freeze

      PERIOD_PARAMS.each { |p| attr_reader p }
      attr_reader :range

      def initialize(period)
        @range = Range.new(*period.minmax.map { |e| Time.parse(e) })
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

        time_intersect?(period)
      end

      def include?(time)
        @range.include?(time)
      end

      private

      def time_intersect?(period)
        return true if include?(period.range.min)
        return true if include?(period.range.max)
        return true if period.include?(@range.min)
        return true if period.include?(@range.max)

        false
      end
    end
  end
end
