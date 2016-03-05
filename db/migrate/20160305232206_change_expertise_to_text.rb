class ChangeExpertiseToText < ActiveRecord::Migration
  def change
    change_column :users, :expertise, :text
  end
end
