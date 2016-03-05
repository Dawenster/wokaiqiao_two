class AddPastWorkToUsers < ActiveRecord::Migration
  def change
    add_column :users, :past_work, :text
  end
end
