class RemoveEducationFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :education
  end
end
