require 'nokogiri'

namespace :incidents do
  # Example invocation: rails incidents:export contrib/Accidents-Incidents.xml
  task export: :environment do
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.object_interface do
        Incident.all.each do |incident|
          report = incident.driver_incident_report
          sup_report = incident.supervisor_report
          xml.accident-incident do
            ai_block           report.block
            xml.ai_code do
              reac_identifier  incident.reason_code.identifier
            end
            ai_commentary      report.description
            ai_date_occured    incident.occurred_at.strftime('%Y-%m-%d')
            ai_direction       report.direction
            ai_dvr_pulled      sup_report.hard_drive_pulled?
            xml.ai_employee do
              demp_display_id  incident.driver.hastus_id
            end
            ai_point_of_impact report.point_of_impact
            ai_route           report.route
            ai_vehicle         report.bus
          end
        end
      end
    end
    File.open ARGV.last, 'w' do |file|
      file.write builder.to_xml
    end
  end

  # Example invocation: rails incidents:import_hastus_ids contrib/Accidents-Incidents.xml
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
