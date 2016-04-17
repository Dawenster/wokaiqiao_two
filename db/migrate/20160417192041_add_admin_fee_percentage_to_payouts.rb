class AddAdminFeePercentageToPayouts < ActiveRecord::Migration
  def change
    add_column :payouts, :admin_fee_percentage, :integer
  end
end
