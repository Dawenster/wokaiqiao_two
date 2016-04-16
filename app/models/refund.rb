class Refund < ActiveRecord::Base
  belongs_to :payment
  belongs_to :user

  validates :amount_in_cents,
            :user_id,
            :payment_id,
            :stripe_re_id,
            :stripe_ch_id,
            :currency,
            presence: true
  validate :cannot_refund_more_than_charged

  def self.make(user, payment, refund)
    Refund.create(
      amount_in_cents: refund.amount,
      currency: StripeTask::CURRENCY,
      user: user,
      payment: payment,
      stripe_re_id: refund.id,
      stripe_ch_id: refund.charge
    )
  end

  private

  def cannot_refund_more_than_charged
    if payment.total_refunds_in_cents < 0
      errors.add(:base, "Cannot refund more than total charged")
    end
  end
end
