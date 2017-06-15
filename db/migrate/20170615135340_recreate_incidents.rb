# frozen_string_literal: true

class RecreateIncidents < ActiveRecord::Migration[5.1]
  def change
    create_table :incidents do |t|
      t.integer :driver_incident_report_id
      t.integer :supervisor_incident_report_id
      t.integer :supervisor_report_id

      t.timestamps
    end
  end
end
