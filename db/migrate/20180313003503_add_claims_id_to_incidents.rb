class AddClaimsIdToIncidents < ActiveRecord::Migration[5.1]
  def change
    add_column :incidents, :claims_id, :integer
  end
end
