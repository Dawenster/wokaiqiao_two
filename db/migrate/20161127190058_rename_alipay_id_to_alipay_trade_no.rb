class RenameAlipayIdToAlipayTradeNo < ActiveRecord::Migration
  def change
    rename_column :payments, :alipay_id, :alipay_trade_no
  end
end
