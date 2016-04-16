class Charge < ActiveRecord::Base
  belongs_to :call
  belongs_to :user

  validates :amount_in_cents,
            :user_id,
            :stripe_py_id,
            :charge_type,
            :currency,
            presence: true

  PAYMENT = "payment"
  REFUND = "refund"
end
