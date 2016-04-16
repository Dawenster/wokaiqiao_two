class Charge < ActiveRecord::Base
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

  private

  def cannot_refund_more_than_charged
    if call.present? && call.charges.sum(:amount_in_cents) < 0
      errors.add(:base, "Cannot refund more than total charged")
    end
  end
end
