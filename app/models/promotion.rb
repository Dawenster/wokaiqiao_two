class Promotion < ActiveRecord::Base
  has_many :credits
  has_and_belongs_to_many :users, uniq: true

  validates :name,
            :code,
            :amount_in_cents,
            :currency,
            :free_call_count,
            :redemption_limit,
            presence: true
  validate :cannot_redeem_past_limit

  scope :has_free_calls, -> {
    where("free_call_count > ?", 0)
  }

  before_save :upcase_code

  def amount
    amount_in_cents / 100
  end

  def has_credits?
    amount_in_cents.present? && amount_in_cents > 0
  end

  def has_free_calls?
    free_call_count.present? && free_call_count > 0
  end

  private

  def upcase_code
    self.code.upcase!
  end

  def cannot_redeem_past_limit
    promo = Promotion.find_by_code(code)
    if promo.present? && promo.users.count > promo.redemption_limit
      errors.add(:redemption_limit, "has been reached")
    end
  end

end
