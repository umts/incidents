class CreateWitnesses < ActiveRecord::Migration[5.1]
  def change
    create_table :witnesses do |t|
      t.integer :supervisor_report_id
      t.string :name
      t.text :address
      t.boolean :onboard_bus
      t.string :home_phone
      t.string :cell_phone
      t.string :work_phone

      t.timestamps
    end
  end
end
