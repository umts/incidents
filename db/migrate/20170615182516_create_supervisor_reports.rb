class CreateSupervisorReports < ActiveRecord::Migration[5.1]
  def change
    create_table :supervisor_reports do |t|
      t.integer :incident_id
      t.integer :user_id
      # t.text :witnesses TODO
      t.boolean :hard_drive_pulled
      t.datetime :hard_drive_pulled_at
      t.string :hard_drive_removed
      t.string :hard_drive_replaced
      t.boolean :pictures_saved
      t.integer :saved_pictures
      t.text :passenger_statement
      t.text :description
      t.datetime :faxed

      t.boolean :completed_drug_or_alcohol_test
      t.string :reason_test_completed # post-accident or reasonable suspicion
      t.string :testing_facility
      t.datetime :testing_facility_notified_at
      t.datetime :employee_notified_of_test_at
      t.datetime :employee_departed_to_test_at
      t.datetime :employee_arrived_at_test_at
      t.datetime :test_started_at
      t.datetime :test_ended_at
      t.datetime :employee_returned_at
      t.datetime :superintendent_notified_at
      t.datetime :program_manager_notified_at
      t.datetime :director_notified_at
      t.text :amplifying_comments

      t.boolean :test_due_to_bodily_injury
      t.boolean :test_due_to_disabling_damage
      t.boolean :test_due_to_fatality
      t.boolean :test_not_conducted

      t.boolean :completed_drug_test
      t.boolean :completed_alcohol_test
      t.datetime :observation_made_at
      t.boolean :test_due_to_employee_appearance
      t.string :employee_appearance
      t.boolean :test_due_to_employee_behavior
      t.string :employee_behavior
      t.boolean :test_due_to_employee_speech
      t.string :employee_speech
      t.boolean :test_due_to_employee_odor
      t.string :employee_odor

      t.timestamps
    end
  end
end
