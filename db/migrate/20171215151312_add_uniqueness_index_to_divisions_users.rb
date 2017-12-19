class AddUniquenessIndexToDivisionsUsers < ActiveRecord::Migration[5.1]
  def change
    add_index :divisions_users, [:division_id, :user_id], unique: true
  end
end
