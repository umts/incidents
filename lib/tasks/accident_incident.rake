require 'nokogiri'

namespace :incidents do
  task export: :environment do
    
  end

  task import_hastus_ids: :environment do
    file = File.open ARGV.last
    doc = Nokogiri::XML file
    imported = 0
    doc.css('accident_incident').each do |inc_data|
      hastus_id = inc_data.at_css('hastus_id').text
      incident = Incident.find_by hastus_id: hastus_id
      next if incident.present?
      user_hastus_id = inc_data.at_css('employee_hastus_id').text
      user = User.find_by hastus_id: user_hastus_id
      unless user.present?
        puts "Could not find user with hastus_id #{user_hastus_id}"
        next
      end
      date = Date.parse inc_data.at_css('date_occurred').text
      time = Time.parse inc_data.at_css('time_occurred').text
      occurred_at = DateTime.new(date.year, date.month, date.day, time.hour, time.minute)
      incident = user.incidents.find_by occurred_at: occurred_at
      unless incident.present?
        puts "Could not find incident for user #{user.name} at datetime #{occurred_at}"
        next
      end
      incident.update hastus_id: hastus_id
      imported += 1
    end
    puts "#{imported.zero? ? 'No new' : imported} incidents associated with Hastus IDs."
  end
end
