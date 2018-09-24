class AddSupplementaryReasonCodeIdToIncidents < ActiveRecord::Migration[5.1]
  def change
    add_column :incidents, :supplementary_reason_code_id, :integer
  end
end
