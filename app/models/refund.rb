class Refund < ActiveRecord::Base
  belongs_to :payment
  belongs_to :user

  validates :amount_in_cents,
            :user_id,
            :payment_id,
            :stripe_pyr_id,
            :stripe_py_id,
            :currency,
            presence: true
  validate :cannot_refund_more_than_charged

  def self.make(user, payment, refund)
    Refund.create(
      amount_in_cents: refund.amount,
      currency: StripeTask::CURRENCY,
      user: user,
      payment: payment,
      stripe_pyr_id: refund.id,
      stripe_py_id: refund.charge
    )
  end

  def self.refund_call(call, amount, customer)
    user_is_alipay = customer.sources.data.first.object == StripeTask::ALIPAY_ACCOUNT
    if user_is_alipay
      Refund.refund_alipay(call, amount, customer)
    else
      Refund.refund_credit_card(call, amount)
    end
  end

  def self.refund_alipay(call, amount, customer)
    # Refund everything and then charge the correct amount
    call.payments.each do |payment|
      next unless payment.can_refund?
      refund = StripeTask.refund(payment.stripe_py_id, payment.remaining_refundable)
      Refund.make(call.user, payment, refund)
    end
    charge = StripeTask.charge(customer, call.cost_in_cents, "和#{call.expert.name}通话")
    Payment.make(call.user, call, charge)
  end

  def self.refund_credit_card(call, amount)
    call.payments.each do |payment|
      return if amount == 0
      next unless payment.can_refund?
      amount_to_refund = amount > payment.remaining_refundable ? payment.remaining_refundable : amount
      refund = StripeTask.refund(payment.stripe_py_id, amount_to_refund)
      Refund.make(call.user, payment, refund)
      amount -= amount_to_refund
    end
  end

  private

  def cannot_refund_more_than_charged
    if payment.remaining_refundable < 0
      errors.add(:base, "Cannot refund more than total charged")
    end
  end
end
