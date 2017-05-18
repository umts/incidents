# frozen_string_literal: true

class AddNameAndStaffToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :name, :string
    add_column :users, :staff, :boolean, default: false
  end
end
