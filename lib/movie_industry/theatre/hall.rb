module MovieIndustry
  class Theatre
    class Hall < DSLThing
      attr_reader :code, :title, :places

      def initialize(code, **params)
        @code = code
        params.each { |k, v| instance_variable_set("@#{k}", v) }
      end
    end
  end
end
