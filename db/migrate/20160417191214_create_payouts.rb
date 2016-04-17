class CreatePayouts < ActiveRecord::Migration
  def change
    create_table :payouts do |t|
      t.integer :expert_id
      t.integer :call_id
      t.integer :amount_in_cents
      t.string :currency

      t.timestamps
    end
  end
end
