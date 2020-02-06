module Cashbox
  require 'money'

  attr_reader :cash

  def setup_cashbox
    Money.locale_backend = :currency
    Money.rounding_mode = BigDecimal::ROUND_HALF_EVEN
    @cash = Money.new(0, 'USD')
  end

  def enroll(amount)
    raise 'You can’t reduce cash' if amount.negative?

    @cash += amount
  end

  def take(who = nil)
    raise 'This is a Robbery!' unless who == 'Bank'

    @cash = Money.new(0)
  end
end
