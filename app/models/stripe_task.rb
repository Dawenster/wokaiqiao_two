class StripeTask

  CURRENCY = "cny"

  def self.customer(user)
    Stripe::Customer.retrieve(user.stripe_cus_id)
  end

  def self.create_stripe_customer(user, token)
    customer = Stripe::Customer.create(
      description: user.name,
      email: user.email,
      source: token
    )
    user.update_attributes(stripe_cus_id: customer.id)
    customer
  end

  def self.charge(customer, amount, description=nil)
    Stripe::Charge.create(
      amount: amount,
      currency: CURRENCY,
      customer: customer,
      description: description
    )
  end

  def self.refund(stripe_ch_id, amount, reason=nil)
    Stripe::Refund.create(
      amount: amount,
      currency: CURRENCY,
      reason: reason
    )
  end

end