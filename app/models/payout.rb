class Payout < ActiveRecord::Base
  belongs_to :call
  belongs_to :expert, class_name: User, foreign_key: :expert_id

  validates :amount_in_cents,
            :expert_id,
            :call_id,
            :currency,
            presence: true

  ADMIN_FEE_PERCENTAGE = 20

  def self.make_for_call(call)
    Payout.create(
      call: call,
      expert: call.expert,
      amount_in_cents: call.expert_payout_in_cents,
      currency: StripeTask::CURRENCY,
      admin_fee_percentage: ADMIN_FEE_PERCENTAGE
    )
  end

end
