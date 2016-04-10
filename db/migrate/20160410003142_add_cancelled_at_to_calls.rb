class AddCancelledAtToCalls < ActiveRecord::Migration
  def change
    add_column :calls, :cancelled_at, :datetime
  end
end
