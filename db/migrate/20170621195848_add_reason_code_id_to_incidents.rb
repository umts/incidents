class AddReasonCodeIdToIncidents < ActiveRecord::Migration[5.1]
  def change
    add_column :incidents, :reason_code_id, :integer
  end
end
