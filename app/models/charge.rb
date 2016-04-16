class Charge < ActiveRecord::Base
  belongs_to :call
  belongs_to :user

  PAYMENT = "payment"
  REFUND = "refund"
end
