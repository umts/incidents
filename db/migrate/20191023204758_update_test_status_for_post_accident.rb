class UpdateTestStatusForPostAccident < ActiveRecord::Migration[5.1]
  def up
    SupervisorReport.all.each do |report|
      if(report.test_status == 'Post Accident' && !report.fta_threshold_not_met && !report.driver_discounted)
        report.test_status = 'Post Accident: Threshold met (completed drug test)'
      end
      report.save(validate: false)
    end
  end
  def down
    SupervisorReport.all.each do |report|
      if(report.test_status == 'Post Accident: Threshold met (completed drug test')
        report.test_status = 'Post Accident'
        report.fta_threshold_not_met = false
        report.driver_discounted = false
      end
    end
  end
end
