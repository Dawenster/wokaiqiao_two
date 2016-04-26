class AddCurrencyToPromotions < ActiveRecord::Migration
  def change
    add_column :promotions, :currency, :string
  end
end
