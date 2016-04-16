class RenameChargesToPayments < ActiveRecord::Migration
  def change
    rename_table :charges, :payments
  end
end
