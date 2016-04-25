class ChangeExpertiseToDescription < ActiveRecord::Migration
  def change
    rename_column :users, :expertise, :description
  end
end
