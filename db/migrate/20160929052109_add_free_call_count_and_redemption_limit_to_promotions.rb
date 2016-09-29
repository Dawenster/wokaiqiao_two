class AddFreeCallCountAndRedemptionLimitToPromotions < ActiveRecord::Migration
  def change
    add_column :promotions, :free_call_count, :integer
    add_column :promotions, :redemption_limit, :integer
  end
end
