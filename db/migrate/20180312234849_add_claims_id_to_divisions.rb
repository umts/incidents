class AddClaimsIdToDivisions < ActiveRecord::Migration[5.1]
  def change
    add_column :divisions, :claims_id, :integer
  end
end
