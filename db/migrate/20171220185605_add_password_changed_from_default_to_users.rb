class AddPasswordChangedFromDefaultToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :password_changed_from_default, :boolean, default: false
  end
end
