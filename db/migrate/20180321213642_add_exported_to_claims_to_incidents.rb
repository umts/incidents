class AddExportedToClaimsToIncidents < ActiveRecord::Migration[5.1]
  def change
    add_column :incidents, :exported_to_claims, :boolean
  end
end
