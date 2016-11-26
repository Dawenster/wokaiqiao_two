class AddAlipayIdToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :alipay_id, :string
  end
end
