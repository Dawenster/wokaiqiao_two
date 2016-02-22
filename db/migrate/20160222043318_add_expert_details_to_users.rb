class AddExpertDetailsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :education, :string
    add_column :users, :expertise, :string
    add_column :users, :current_work, :string
    add_column :users, :rate_per_minute, :integer
  end
end
