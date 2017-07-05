# frozen_string_literal: true

require 'nokogiri'

namespace :incidents do

  # Example invocation: rails incidents:import_hastus_ids contrib/Incidents.xml
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
      next unless user.present?
      date = Date.parse inc_data.at_css('date_occurred').text
      time = Time.parse inc_data.at_css('time_occurred').text
      occurred_at = DateTime.new(date.year, date.month, date.day,
                                 time.hour, time.minute)
      incident = user.incidents.find_by occurred_at: occurred_at
      next unless incident.present?
      incident.update hastus_id: hastus_id
      imported += 1
    end
    count = imported.zero? ? 'No new' : imported
    puts "#{count} incidents associated with Hastus IDs."
  end
end
