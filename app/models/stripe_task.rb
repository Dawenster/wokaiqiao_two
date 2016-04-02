class StripeTask

  CURRENCY = "CNY"

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

end