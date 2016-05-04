class CreateExpertsTags < ActiveRecord::Migration
  def change
    create_table :experts_tags do |t|
      t.integer :expert_id
      t.integer :tag_id

      t.timestamps
    end
  end
end
