class Credit < ActiveRecord::Base
  belongs_to :call
  belongs_to :promotion
  belongs_to :user

  validates :amount_in_cents,
            :currency,
            :promotion_id,
            presence: true

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

end
