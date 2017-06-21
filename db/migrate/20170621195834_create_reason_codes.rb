class CreateReasonCodes < ActiveRecord::Migration[5.1]
  def change
    create_table :reason_codes do |t|
      t.string :identifier
      t.text :description
    end
  end
end
