class Payment < ActiveRecord::Base
  belongs_to :call
  belongs_to :user
  has_many :refunds

  validates :amount_in_cents,
            :user_id,
            :stripe_py_id,
            :currency,
            presence: true

  def self.make(user, call, amount, trade_no)
    Payment.create(
      amount_in_cents: amount,
      currency: Alipay::Pay::CURRENCY,
      call: call,
      user: user,
      alipay_trade_no: trade_no
    )
  end

  def can_refund?
    amount_in_cents > total_refunds_in_cents
  end

  def remaining_refundable
    amount_in_cents - total_refunds_in_cents
  end

  def total_refunds_in_cents
    refunds.sum(:amount_in_cents)
  end
end
