class CreateRefunds < ActiveRecord::Migration
  def change
    create_table :refunds do |t|
      t.integer :amount_in_cents
      t.integer :stripe_re_id
      t.integer :payment_id
      t.integer :stripe_ch_id
      t.text :notes
      t.string :currency

      t.timestamps
    end
  end
end
