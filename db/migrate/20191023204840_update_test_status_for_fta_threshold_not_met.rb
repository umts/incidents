class UpdateTestStatusForFtaThresholdNotMet < ActiveRecord::Migration[5.1]
  def up
    SupervisorReport.all.each do |report|
      if report.fta_threshold_not_met
        report.test_status = 'Post Accident: No threshold met (no drug test)'
      end
      report.save(validate: false)
    end
  end
  def down
    SupervisorReport.all.each do |report|
      if report.test_status == "Post Accident: No threshold met (no drug test)"
        report.test_status = 'Post Accident'
        report.fta_threshold_not_met = true
      end
      report.save(validate: false)
    end
  end

end
