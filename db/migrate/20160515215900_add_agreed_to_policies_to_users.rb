class AddAgreedToPoliciesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :agreed_to_policies, :boolean
  end
end
