class StripeTask

  CURRENCY = "cny"
  ALIPAY_ACCOUNT = "alipay_account"
  STATUS = [
    SUCCEEDED = :succeeded,
    PENDING = :pending,
    FAILED = :failed
  ]

  # invalid_number  The card number is not a valid credit card number.
  # invalid_expiry_month  The card's expiration month is invalid.
  # invalid_expiry_year The card's expiration year is invalid.
  # invalid_cvc The card's security code is invalid.
  # incorrect_number  The card number is incorrect.
  # expired_card  The card has expired.
  # incorrect_cvc The card's security code is incorrect.
  # incorrect_zip The card's zip code failed validation.
  # card_declined The card was declined.
  # missing There is no card on a customer that is being charged.
  # processing_error  An error occurred while processing the card.

  ERRORS = {
    "invalid_number" => "信用卡卡号错误",
    "invalid_expiry_month" => "信用卡有效到期月份错误",
    "invalid_expiry_year" => "信用卡有效到期年份错误",
    "invalid_cvc" => "信用卡安全认证码错误",
    "incorrect_number" => "信用卡卡号错误",
    "expired_card" => "信用卡已过期",
    "incorrect_cvc" => "信用卡安全认证码错误",
    "incorrect_zip" => "邮政编码错误",
    "card_declined" => "信用卡被拒绝：请检查信用卡资料，如问题并未解决，请联系发卡机构",
    "missing" => "信用卡资料不存在，请重新填写",
    "processing_error" => "信用卡无法通过认证：请检查信用卡资料，如问题并未解决，请联系发卡机构"
  }

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
  rescue Stripe::CardError => e
    body = e.json_body
    err = body[:error]
    error_message = ERRORS[err[:code]] || "你的收费没成功"
    {
      status: :failed,
      error_message: error_message
    }
  end

  def self.refund(stripe_py_id, amount, reason=nil)
    Stripe::Refund.create(
      charge: stripe_py_id,
      amount: amount,
      reason: reason
    )
  end

  def self.failed_charge?(charge)
    charge[:status] == FAILED
  end

end