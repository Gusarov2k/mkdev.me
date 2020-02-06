module MovieIndustry
  module Cashbox
    require 'money'

    attr_reader :cashbox_balance

    def setup_cashbox
      Money.locale_backend = :currency
      Money.rounding_mode = BigDecimal::ROUND_HALF_EVEN
      @cashbox_balance = Money.new(0, 'USD')
    end

    def cash
      setup_cashbox if @cashbox_balance.nil?
      @cashbox_balance
    end

    def enroll(amount)
      raise 'You can’t reduce cash' if amount.negative?

      @cashbox_balance += amount
    end

    def take(who = nil)
      raise 'This is a Robbery!' unless who == 'Bank'

      @cashbox_balance = Money.new(0)
    end
  end
end
