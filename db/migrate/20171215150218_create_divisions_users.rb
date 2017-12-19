class CreateDivisionsUsers < ActiveRecord::Migration[5.1]
  def change
    create_join_table :divisions, :users
  end
end
