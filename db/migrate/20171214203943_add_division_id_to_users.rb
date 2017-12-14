class AddDivisionIdToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :division_id, :integer
  end
end
