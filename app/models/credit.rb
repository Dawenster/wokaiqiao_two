class Credit < ActiveRecord::Base
  belongs_to :call
  belongs_to :promotion

  validates :amount_in_cents,
            :currency,
            :promotion_id,
            presence: true

end
