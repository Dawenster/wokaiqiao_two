class AddCancelledByToCalls < ActiveRecord::Migration
  def change
    add_column :calls, :cancelled_by, :integer
  end
end
