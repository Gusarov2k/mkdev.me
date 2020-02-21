module MovieIndustry
  class Theatre
    class Config
      attr_accessor :halls, :periods

      def initialize
        @halls = {}
        @periods = {}
      end

      def period_by_time(time)
        @periods.values.select { |p| p.include?(time) }.sample
      end
    end
  end
end
