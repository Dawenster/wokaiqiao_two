class CreateFakeComments < ActiveRecord::Migration
  def change
    create_table :fake_comments do |t|
      t.integer :user_id
      t.string :name
      t.text :review
      t.datetime :reviewed_at
      t.string :profile_pic_url

      t.timestamps
    end
  end
end
