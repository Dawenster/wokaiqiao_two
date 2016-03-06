class AddDomesticToUsers < ActiveRecord::Migration
  def change
    add_column :users, :domestic, :boolean
  end
end
