class AddSecondReasonCodeToIncidents < ActiveRecord::Migration[5.1]
  def change
    add_column :incidents, :second_reason_code, :string
  end
end
