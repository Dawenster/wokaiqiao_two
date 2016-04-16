class AddUserIdToRefunds < ActiveRecord::Migration
  def change
    add_column :refunds, :user_id, :integer
  end
end
