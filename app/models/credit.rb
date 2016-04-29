class Credit < ActiveRecord::Base
  belongs_to :call
  belongs_to :promotion
  belongs_to :user

  validates :amount_in_cents,
            :currency,
            :user_id,
            presence: true
  validate :always_positive_net_credits_per_user

  scope :received, -> {
    where("amount_in_cents > 0")
  }

  scope :used, -> {
    where("amount_in_cents < 0")
  }

  EARNED = "赚得"
  USED = "使用"

  def self.create_for(user, promotion)
    Credit.create(
      user: user,
      promotion: promotion,
      amount_in_cents: promotion.amount_in_cents,
      currency: promotion.currency
    )
  end

  def self.user_on(call, amount_in_cents)
    Credit.create(
      user: call.user,
      call: call,
      amount_in_cents: -(amount_in_cents),
      currency: StripeTask::CURRENCY
    )
  end

  def amount
    amount_in_cents / 100
  end

  def credit_type
    if is_earned?
      EARNED
    elsif is_used?
      USED
    end
  end

  def is_earned?
    amount_in_cents > 0
  end

  def is_used?
    amount_in_cents < 0
  end

  private

  def always_positive_net_credits_per_user
    if user.net_credits_in_cents < 0
      errors.add(:base, "Net credits cannot be less than zero")
    end
  end

end
