class UpdateTestStatusColumnForDiscountedDrivers < ActiveRecord::Migration[5.1]
  def change
    SupervisorReport.all.each do |report|
      if(report.driver_discounted)
        report.test_status = 'Post Accident: Threshold met and discounted (no drug test)'
      end
      report.save(validate: false)
    end
  end
end
