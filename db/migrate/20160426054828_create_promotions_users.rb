class CreatePromotionsUsers < ActiveRecord::Migration
  def change
    create_table :promotions_users do |t|
      t.integer :promotion_id
      t.integer :user_id

      t.timestamps
    end
  end
end
