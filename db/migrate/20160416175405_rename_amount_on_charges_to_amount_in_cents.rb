class RenameAmountOnChargesToAmountInCents < ActiveRecord::Migration
  def change
    rename_column :charges, :amount, :amount_in_cents
  end
end
