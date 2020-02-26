module MovieIndustry
  class Theatre
    class Config
      attr_accessor :halls, :periods

      def initialize
        @halls = {}
        @periods = []
      end

      def choose_period(time:, hall: nil)
        periods = @periods.select { |p| p.include?(time) }
        hall ? periods.detect { |p| p.hall.include?(hall) } : periods.sample
      end

      def select_periods(time:)
        @periods.select { |p| p.include?(time) }
      end

      def find_movie_period(movie)
        periods.detect { |p| p.matche_movie?(movie) }
      end

      def existing_halls
        @halls.values.map(&:code)
      end
    end
  end
end
