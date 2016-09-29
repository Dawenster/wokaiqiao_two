class AddFreeToCalls < ActiveRecord::Migration
  def change
    add_column :calls, :free, :boolean, default: false
  end
end
