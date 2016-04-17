class Payout < ActiveRecord::Base
  belongs_to :call
  belongs_to :expert, class_name: User, foreign_key: :expert_id

  validates :amount_in_cents,
            :expert_id,
            :call_id,
            :currency,
            presence: true

end
