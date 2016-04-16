class Payment < ActiveRecord::Base
  belongs_to :call
  belongs_to :user

  validates :amount_in_cents,
            :user_id,
            :stripe_py_id,
            :currency,
            presence: true
  validate :cannot_refund_more_than_charged

  def self.make(user, call, charge)
    Payment.create(
      amount_in_cents: charge.amount,
      currency: StripeTask::CURRENCY,
      call: call,
      user: user,
      stripe_py_id: charge.id
    )
  end

  private

  def cannot_refund_more_than_charged
    if call.present? && call.total_charged_in_cents < 0
      errors.add(:base, "Cannot refund more than total charged")
    end
  end
end
