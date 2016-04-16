class RemoveChargeTypeFromPayments < ActiveRecord::Migration
  def change
    remove_column :payments, :charge_type
  end
end
