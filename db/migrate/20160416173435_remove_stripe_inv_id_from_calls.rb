class RemoveStripeInvIdFromCalls < ActiveRecord::Migration
  def change
    remove_column :calls, :stripe_inv_id
  end
end
