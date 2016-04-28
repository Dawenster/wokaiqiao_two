class Promotion < ActiveRecord::Base
  has_many :credits
  has_many :promotions_users
  has_and_belongs_to_many :users, -> { uniq }

  validates :name,
            :code,
            :amount_in_cents,
            :currency,
            presence: true

  before_save :upcase_code

  def amount
    amount_in_cents / 100
  end

  private

  def upcase_code
    self.code.upcase!
  end

end
