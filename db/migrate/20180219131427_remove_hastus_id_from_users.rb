class RemoveHastusIdFromUsers < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :hastus_id, :integer
  end
end
