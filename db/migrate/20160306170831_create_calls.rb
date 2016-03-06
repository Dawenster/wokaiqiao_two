class CreateCalls < ActiveRecord::Migration
  def change
    create_table :calls do |t|
      t.text :description
      t.integer :est_duration_in_min
      t.integer :user_id
      t.integer :expert_id
      t.integer :user_rating
      t.integer :expert_rating
      t.text :user_review
      t.text :expert_review
      t.datetime :offer_time_one
      t.datetime :offer_time_two
      t.datetime :offer_time_three
      t.datetime :scheduled_at
      t.datetime :user_accepted_at
      t.datetime :expert_accepted_at

      t.timestamps
    end
  end
end
