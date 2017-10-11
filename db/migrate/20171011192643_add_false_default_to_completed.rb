class AddFalseDefaultToCompleted < ActiveRecord::Migration[5.1]
  def change
    change_column :incidents, :completed, :boolean, default: false
  end
end
