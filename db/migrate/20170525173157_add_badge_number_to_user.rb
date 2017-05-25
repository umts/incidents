class AddBadgeNumberToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :badge_number, :string
  end
end
