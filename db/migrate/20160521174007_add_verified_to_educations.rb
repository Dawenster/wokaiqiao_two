class AddVerifiedToEducations < ActiveRecord::Migration
  def change
    add_column :educations, :verified, :boolean
  end
end
