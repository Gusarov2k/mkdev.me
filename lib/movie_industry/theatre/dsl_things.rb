module MovieIndustry
  class Theatre
    class DSLThing
      def copyvars
        self.class.instance_variables.each do |var|
          instance_variable_set(var, self.class.instance_variable_get(var))
        end
      end
    end
  end
end
