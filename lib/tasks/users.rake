require 'nokogiri'

namespace :users do
  # Given a newline-separated list of supervisors, elevate them to be staff.
  # Example:
  #
  # David Faulkenberry
  # Adam Sherson
  # Matt Moretti
  #
  # Example invocation: rails users:elevate_staff contrib/staff.txt
  task elevate_staff: :environment do
    file = File.open(ARGV[1] || 'contrib/staff.txt')
    text = file.read
    elevated = 0
    text.each_line do |name|
      first_name, last_name = name.split ' '
      user = User.supervisors.find_by first_name: first_name,
                                      last_name: last_name
      unless user.present?
        puts "Could not find supervisor with name #{name}" 
        next
      end
      user.update staff: true
      elevated += 1
    end
    puts "#{elevated.zero? ? 'No' : elevated} supervisors were elevated to staff."
  end


  # Example invocation rails users:import contrib/Users.xml
  task import: :environment do
    file = File.open(ARGV[1] || 'contrib/Users.xml')
    doc = Nokogiri::XML file
    imported = 0
    doc.css('User').each do |user_data|
      attrs = {}
      attrs[:hastus_id] = user_data.at_css('hastus_id').text
      user = User.find_by attrs
      unless user.present?
        attrs[:first_name] = user_data.at_css('first_name').text.capitalize
        attrs[:last_name] = user_data.at_css('last_name').text.capitalize
        attrs[:division] = user_data.at_css('division').text.capitalize
        job_class = user_data.at_css('job_class').text
        attrs[:supervisor] = job_class == 'Supervisor'
        user = User.new attrs
        if user.save
          imported += 1
        else
          print 'Could not create user with attributes '
          puts attrs
          puts user.errors.full_messages
          puts
        end
      end
    end
    puts "#{imported.zero? ? 'No new' : imported} users were imported."
  end
end
