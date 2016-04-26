class CreatePromotions < ActiveRecord::Migration
  def change
    create_table :promotions do |t|
      t.string :name
      t.string :code
      t.integer :amount_in_cents

      t.timestamps
    end
  end
end
