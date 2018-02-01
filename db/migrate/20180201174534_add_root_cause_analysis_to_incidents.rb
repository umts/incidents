class AddRootCauseAnalysisToIncidents < ActiveRecord::Migration[5.1]
  def change
    add_column :incidents, :root_cause_analysis, :text
  end
end
