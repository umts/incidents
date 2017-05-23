class DropIncidents < ActiveRecord::Migration[5.1]
  def up
    drop_table :incidents
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
