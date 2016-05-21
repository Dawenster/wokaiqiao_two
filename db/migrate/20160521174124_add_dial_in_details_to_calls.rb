class AddDialInDetailsToCalls < ActiveRecord::Migration
  def change
    add_column :calls, :conference_call_number, :string
    add_column :calls, :conference_call_admin_code, :string
    add_column :calls, :conference_call_participant_code, :string
  end
end
