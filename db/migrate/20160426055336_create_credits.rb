class CreateCredits < ActiveRecord::Migration
  def change
    create_table :credits do |t|
      t.integer :amount_in_cents
      t.string :currency
      t.integer :promotion_id
      t.integer :call_id

      t.timestamps
    end
  end
end
