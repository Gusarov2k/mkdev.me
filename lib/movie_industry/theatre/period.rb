module MovieIndustry
  class Theatre
    class Period
      attr_reader :range

      def initialize(key, &block)
        @range = Range.new(*key.minmax.map { |e| Time.parse(e) })
        @description = nil
        @filters = {}
        @price = nil
        @hall = []
        instance_eval(&block) if block_given?
      end

      def description(arg = nil)
        return @description unless arg

        @description = arg
      end

      def filters(arg = nil)
        return @filters unless arg

        @filters = format_filter(arg)
      end

      def title(arg)
        @filters = @filters.merge(title: arg)
      end

      def price(arg = nil)
        return @price unless arg

        @price = Money.new(arg * 100, 'USD')
      end

      def hall(*args)
        return @hall unless args.any?

        @hall = args
      end

      def intersect?(period)
        return false unless (hall & period.hall).any?

        time_intersect?(period)
      end

      def include?(time)
        @range.include?(time)
      end

      def to_s
        "Period: '#{description}' showing #{print_filtres}"
      end

      def matche_movie?(movie)
        result = @filters.inject(movie) { |acc, (k, v)| acc&.matches?(k, v) ? acc : nil }
        !result.nil?
      end

      private

      def print_filtres
        msg = filters.map do |key, val|
          case key
          when :genre then "Genre: #{val.source.gsub('|', ' or ')}"
          when :year then "Year: #{val.minmax.join('-')}"
          when :title then "Title: '#{val}'"
          when :exclude_country then "Exclude country: #{val}"
          end
        end
        msg.join(', ')
      end

      def format_filter(filter)
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
