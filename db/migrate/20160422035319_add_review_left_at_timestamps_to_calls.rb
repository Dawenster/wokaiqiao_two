class AddReviewLeftAtTimestampsToCalls < ActiveRecord::Migration
  def change
    add_column :calls, :user_review_left_at, :datetime
    add_column :calls, :expert_review_left_at, :datetime
  end
end
