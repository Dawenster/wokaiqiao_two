class Promotion < ActiveRecord::Base
  has_many :credits
  has_and_belongs_to_many :users

  validates :name,
            :code,
            :amount_in_cents,
            :currency,
            presence: true

end
