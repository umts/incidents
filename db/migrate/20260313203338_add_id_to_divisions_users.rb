# frozen_string_literal: true

class AddIdToDivisionsUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :divisions_users, :id, :primary_key
  end
end
