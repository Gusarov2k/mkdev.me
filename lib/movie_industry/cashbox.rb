module MovieIndustry
  module Cashbox
    require 'money'
    require_relative './cashbox/setup_money'
    include SetupMoney

    def cash
      @cash.nil? ? @cash = setup_money : @cash
    end

    def enroll(amount)
      raise 'You can’t reduce cash' if amount.negative?

      @cash = cash + amount
    end

    def take(who = nil)
      raise 'This is a Robbery!' unless who == 'Bank'

      @cash = Money.new(0)
    end
  end
end
