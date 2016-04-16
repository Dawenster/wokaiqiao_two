class Payment < ActiveRecord::Base
  belongs_to :call
  belongs_to :user
  has_many :refunds

  validates :amount_in_cents,
            :user_id,
            :stripe_py_id,
            :currency,
            presence: true

  def self.make(user, call, charge)
    Payment.create(
      amount_in_cents: charge.amount,
      currency: StripeTask::CURRENCY,
      call: call,
      user: user,
      stripe_py_id: charge.id
    )
  end

  def can_refund?
    total_refunds_in_cents == amount_in_cents
  end

  def remaining_refundable
    amount_in_cents - total_refunds_in_cents
  end

  def total_refunds_in_cents
    refunds.sum(:amount_in_cents)
  end
end
