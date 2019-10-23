class UpdateTestStatusForReasonableSuspicion < ActiveRecord::Migration[5.1]
  def up
    SupervisorReport.all.each do |report|
      if(report.test_status == 'Reasonable Suspicion' && !report.fta_threshold_not_met && !report.driver_discounted)
        report.test_status = 'Reasonable Suspicion: Completed drug test'
      end
      report.save(validate: false)
    end
  end
  def down
    SupervisorReport.all.each do |report|
      if(report.test_status == "Reasonable Suspicion: Completed drug test")
        report.test_status = 'Reasonable Suspicion'
        report.fta_threshold_not_met = false
        report.driver_discounted = false
      end
      report.save(validate: false)
    end
  end
end
