require 'nokogiri'

namespace :reason_codes do
  # Example invocation: rails reason_codes:import contrib/Reason\ codes.xml
  task import: :environment do
    file = File.open ARGV[1]
    doc = Nokogiri::XML file
    imported = 0
    doc.css('ReasonCode').each do |code_data|
      identifier = code_data.at_css('identifier').text
      code = ReasonCode.find_by identifier: identifier
      unless code.present?
        description = code_data.at_css('description').text
        ReasonCode.create! identifier: identifier, description: description
        print '.'
        imported += 1
      end
    end
    puts
    puts "#{imported.zero? ? 'No new' : imported} reason codes imported."
  end

  # Example invocation: rails reason_codes:export contrib/Reason\ codes.xml
  task export: :environment do
    builder = Nokogiri::XML::Builder.new encoding: 'utf-8' do |xml|
      xml.object_interface do
        ReasonCode.all.each do |code|
          xml.daily_reason_code do
            xml.reac_identifier code.identifier
            xml.reac_description code.description
            xml.reac_for_acc_inc true
          end
        end
      end
    end
    File.open ARGV[1], 'w' do |file|
      file.write builder.to_xml
    end
  end
end
