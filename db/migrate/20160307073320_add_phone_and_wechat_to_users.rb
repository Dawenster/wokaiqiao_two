class AddPhoneAndWechatToUsers < ActiveRecord::Migration
  def change
    add_column :users, :phone, :string
    add_column :users, :wechat, :string
  end
end
