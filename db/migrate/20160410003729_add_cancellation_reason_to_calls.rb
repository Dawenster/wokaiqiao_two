class AddCancellationReasonToCalls < ActiveRecord::Migration
  def change
    add_column :calls, :cancellation_reason, :string
  end
end
