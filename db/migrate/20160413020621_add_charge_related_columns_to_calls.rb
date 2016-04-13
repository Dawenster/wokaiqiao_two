class AddChargeRelatedColumnsToCalls < ActiveRecord::Migration
  def change
    add_column :calls, :started_at, :datetime
    add_column :calls, :ended_at, :datetime
    add_column :calls, :stripe_inv_id, :string
  end
end
