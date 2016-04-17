class ChangeStripeIdsOnRefundsToStrings < ActiveRecord::Migration
  def change
    change_column :refunds, :stripe_re_id, :string
    change_column :refunds, :stripe_ch_id, :string
  end
end
