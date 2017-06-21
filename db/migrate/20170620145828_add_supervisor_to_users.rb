class AddSupervisorToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :supervisor, :boolean, default: false
  end
end
