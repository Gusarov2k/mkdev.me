module Cashbox
  attr_accessor :cash

  def enroll(amount)
    raise 'You can’t reduce cash' if amount.negative?

    @cash += amount
  end
end
