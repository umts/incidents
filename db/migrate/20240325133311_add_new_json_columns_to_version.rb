class AddNewJsonColumnsToVersion < ActiveRecord::Migration[6.1]
  def change
    change_table :versions do |t|
      t.rename :object, :old_object
      t.rename :object_changes, :old_object_changes
      t.json :object
      t.json :object_changes
    end
  end
end
