# frozen_string_literal: true

class RemoveDivisionFromUser < ActiveRecord::Migration[8.1]
  def change
    remove_column :users, :division, :string
  end
end
