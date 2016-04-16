class AddChargeTypeToCharges < ActiveRecord::Migration
  def change
    add_column :charges, :charge_type, :string
  end
end
