require 'nokogiri'

namespace :users do
  # Example invocation rails users:import contrib/Users.xml
  task import: :environment do
    file = File.open ARGV[1]
    doc = Nokogiri::XML file
    imported = 0
    doc.css('User').each do |user_data|
      attrs = {}
      attrs[:hastus_id] = user_data.at_css('hastus_id').text
      user = User.find_by attrs
      unless user.present?
        first_name = user_data.at_css('first_name').text
        last_name = user_data.at_css('last_name').text
        attrs[:name] = [first_name, last_name].join ' '
        job_class = user_data.at_css('job_class').text
        attrs[:supervisor] = job_class == 'Supervisor'
        User.create! attrs
        print '.'
        imported += 1
      end
    end
    puts
    puts "#{imported.zero? ? 'No new' : imported} users imported."
  end
end
