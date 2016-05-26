class AddUseFakeCommentsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :use_fake_comments, :boolean
  end
end
