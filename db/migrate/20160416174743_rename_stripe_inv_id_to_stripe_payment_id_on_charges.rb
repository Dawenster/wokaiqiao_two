class RenameStripeInvIdToStripePaymentIdOnCharges < ActiveRecord::Migration
  def change
    rename_column :charges, :stripe_inv_id, :stripe_py_id
  end
end
