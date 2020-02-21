module MovieIndustry
  class Theatre
    class Period
      PERIOD_PARAMS = %i[description filters title price hall].freeze
      attr_reader :range

      def initialize(period, &block)
        @range = Range.new(*period.minmax.map { |e| Time.parse(e) })
        instance_eval(&block) if block_given?
      end

      def method_missing(meth, *args, &block)
        return super unless PERIOD_PARAMS.include?(meth)

        args.empty? ? instance_variable_get("@#{meth}") : instance_variable_set("@#{meth}", format_by(meth, args))
      end

      def respond_to_missing?(method, *)
        PERIOD_PARAMS.include?(method) || super
      end

      def intersect?(period)
        return false unless (hall & period.hall).any?

        time_intersect?(period)
      end

      def include?(time)
        @range.include?(time)
      end

      def to_s
        "#{description}: filters #{filters}, title: #{title}"
      end

      private

      def format_by(meth, args)
        case meth
        when :hall then args
        when :filters then format_filter(args)
        else args.first
        end
      end

      def format_filter(args)
        filter = args.first
        if filter[:genre].is_a?(String)
          filter[:genre] = Regexp.new(filter[:genre])
        elsif filter[:genre].is_a?(Array)
          filter[:genre] = Regexp.new(filter[:genre].join('|'))
        end
        filter
      end

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
