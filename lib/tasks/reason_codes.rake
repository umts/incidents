# frozen_string_literal: true

require 'nokogiri'

namespace :reason_codes do
  # Example invocation: rails reason_codes:import contrib/Reason\ codes.xml
  task import: :environment do
    file = File.open(ARGV[1] || 'contrib/Reason codes.xml')
    doc = Nokogiri::XML file
    imported = 0
    doc.css('reason_code').each do |code_data|
      identifier = code_data.at_css('identifier').text
      code = ReasonCode.find_by identifier: identifier
      next if code.present?
      description = code_data.at_css('description').text
      ReasonCode.create! identifier: identifier, description: description
      imported += 1
    end
    puts "#{imported.zero? ? 'No new' : imported} reason codes were imported."
  end
end
