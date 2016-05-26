class CreatePartnershipRequests < ActiveRecord::Migration
  def change
    create_table :partnership_requests do |t|
      t.string :name
      t.string :school
      t.string :email

      t.timestamps
    end
  end
end
