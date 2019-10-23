class UpdateTestStatusColumnForThresholdNotMet < ActiveRecord::Migration[5.1]
  def change
    SupervisorReport.all.each do |report|
      if(report.fta_threshold_not_met)
        report.test_status = 'Post Accident: No threshold met (no drug test)'
      end
      report.save(validate: false)
    end
  end
end
