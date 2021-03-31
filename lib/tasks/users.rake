# frozen_string_literal: true

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
    puts "#{elevated.zero? ? 'No' : elevated} supervisors were elevated."
  end

  # Example invocation rails users:import contrib/Users.xml
  task import: :environment do
    file = File.open(ARGV[1] || 'contrib/Users.xml')
    doc = Nokogiri::XML file
    statuses = User.import_from_xml(doc)
    if statuses
      message = "Imported #{statuses[:imported]} new users"
      message += " and updated #{statuses[:updated]}" unless statuses[:updated].zero?
      message += '.'
      message << " #{statuses[:rejected]} were rejected." unless statuses[:rejected].zero?
      puts message
    else puts 'Could not import from file.'
    end
  end
end
