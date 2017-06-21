require 'nokogiri'

namespace :reason_codes do
  # Example invocation: rails reason_codes:import contrib/Reason\ codes.xml
  task import: :environment do
    file = File.open ARGV[1]
    doc = Nokogiri::XML file
    doc.css('ReasonCode').each do |code_data|
      identifier = code_data.at_css('identifier').text
      code = ReasonCode.find_by identifier: identifier
      unless code.present?
        description = code_data.at_css('description').text
        ReasonCode.create! identifier: identifier, description: description
      end
    end
  end
end
