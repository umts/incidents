class AddClaimNumberToIncidents < ActiveRecord::Migration[5.1]
  def change
    add_column :incidents, :claim_number, :string
  end
end
