class RenameStripeIdsOnRefundsToAccurateIdNames < ActiveRecord::Migration
  def change
    rename_column :refunds, :stripe_re_id, :stripe_pyr_id
    rename_column :refunds, :stripe_ch_id, :stripe_py_id
  end
end
