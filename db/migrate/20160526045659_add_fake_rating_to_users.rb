class AddFakeRatingToUsers < ActiveRecord::Migration
  def change
    add_column :users, :use_fake_rating, :boolean
    add_column :users, :fake_rating, :integer
  end
end
