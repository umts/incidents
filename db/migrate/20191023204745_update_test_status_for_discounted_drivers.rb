class UpdateTestStatusForDiscountedDrivers < ActiveRecord::Migration[5.1]
  def up
    SupervisorReport.all.each do |report|
      if report.driver_discounted
        report.test_status = 'Post Accident: Threshold met and discounted (no drug test)'
      end
      report.save(validate: false)
    end
  end
    def down
    SupervisorReport.all.each do |report|
      if report.test_status == "Post Accident: Threshold met and discounted (no drug test)"
        report.driver_discounted = true
      end
      report.save(validate: false)
    end
  end
end
