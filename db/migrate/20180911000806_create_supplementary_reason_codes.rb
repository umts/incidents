class CreateSupplementaryReasonCodes < ActiveRecord::Migration[5.1]
  def change
    create_table :supplementary_reason_codes do |t|
      t.string :identifier
      t.string :description
    end
  end
end
