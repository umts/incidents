class CreateStaffReviews < ActiveRecord::Migration[5.1]
  def change
    create_table :staff_reviews do |t|
      t.integer :incident_id
      t.integer :user_id
      t.text :text

      t.timestamps
    end
  end
end
