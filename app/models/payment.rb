class Payment < ActiveRecord::Base
  belongs_to :call
  belongs_to :user

  validates :amount_in_cents,
            :user_id,
            :stripe_py_id,
            :charge_type,
            :currency,
            presence: true
  validate :cannot_refund_more_than_charged

  PAYMENT = "payment"
  REFUND = "refund"

  def self.payment(user, call, charge)
    Payment.create(
      amount_in_cents: charge.amount,
      currency: StripeTask::CURRENCY,
      call: call,
      user: user,
      charge_type: PAYMENT,
      stripe_py_id: charge.id
    )
  end

  def self.refund(user, call, refund)
    Payment.create(
      amount_in_cents: -1 * refund.amount,
      currency: StripeTask::CURRENCY,
      call: call,
      user: user,
      charge_type: REFUND,
      stripe_re_id: refund.id
    )
  end

  private

  def cannot_refund_more_than_charged
    if call.present? && call.total_charged_in_cents < 0
      errors.add(:base, "Cannot refund more than total charged")
    end
  end
end
