module MovieIndustry
  module Cashbox
    module SetupMoney
      require 'money'

      private

      def setup_money
        Money.locale_backend = :currency
        Money.rounding_mode = BigDecimal::ROUND_HALF_EVEN
        Money.new(0, 'USD')
      end
    end
  end
end
