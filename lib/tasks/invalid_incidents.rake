namespace :incidents do
  desc 'fix invalid incidents'
  task update_incidents: :environment do
    completed = Incident.where(completed: true)
    completed.each do |incident|
      unless incident.valid?
        incident.completed = false
        incident.save
      end
    end
  end
end
