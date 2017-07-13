class CreateInjuredPassengers < ActiveRecord::Migration[5.1]
  def change
    create_table :injured_passengers do |t|
      t.integer :supervisor_report_id
      t.string :name
      t.text :address
      t.string :nature_of_injury
      t.boolean :transported_to_hospital
      t.string :home_phone
      t.string :cell_phone
      t.string :work_phone
    end
  end
end
