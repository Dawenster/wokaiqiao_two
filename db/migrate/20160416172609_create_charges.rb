class CreateCharges < ActiveRecord::Migration
  def change
    create_table :charges do |t|
      t.integer :amount
      t.integer :call_id
      t.integer :user_id
      t.text :notes
      t.string :stripe_inv_id

      t.timestamps
    end
  end
end
