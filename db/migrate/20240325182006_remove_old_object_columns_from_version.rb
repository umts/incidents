class RemoveOldObjectColumnsFromVersion < ActiveRecord::Migration[6.1]
  def change
    remove_column :versions, :old_object, :text
    remove_column :versions, :old_object_changes, :text
  end
end
