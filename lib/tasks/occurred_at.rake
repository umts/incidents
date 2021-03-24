namespace :incidents do
  desc 'move occurred_at to incidents'
  task move_occurred_at: :environment do
    Incident.all.each do |incident|
      if incident.driver_incident_report?
        occurred_at = incident.driver_incident_report.occurred_at
        incident.update(occurred_at: occurred_at)
      end
    end
  end
end
