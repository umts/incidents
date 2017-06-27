# PDF is 740 x 560

prawn_document do |pdf|
=begin
  report = @incident.driver_incident_report

  pdf.start_new_page
  pdf.bounding_box [0, pdf.bounds.height], width: 380, height: 80 do
    pdf.move_down 5
    pdf.font 'Times-Roman', size: 30 do
      pdf.text 'SATCo / VATCo', align: :center
    end
    pdf.text 'Operator Incident / Accident Report', size: 18, align: :center
    pdf.text 'Fill in all applicable blanks. Be specific. Use black ink only.',
      align: :center, style: :bold
  end
  pdf.bounding_box [380, pdf.bounds.height], width: 180, height: 80 do
    pdf.move_down 8
    pdf.bounds.add_left_padding 5
    ['File #', 'Code', 'Cause', 'Claim case #'].each do |field|
      pdf.text field
      pdf.move_down 4
    end
  end

  pdf.field_row height: 25, units: 8 do |row|
    row.text_field width: 4, field: 'Operator', value: report.user.proper_name
    row.text_field field: 'Badge No.', value: report.user.badge_number
    row.text_field field: 'Run #', value: report.run
    row.text_field field: 'Block #', value: report.block
    row.text_field field: 'Bus #', value: report.bus
  end

  pdf.field_row height: 30, units: 6 do |row|
    row.text_field field: 'Date of Incident', value: @incident.occurred_at.try(:strftime, '%m/%d/%Y')
    row.text_field field: 'Time of Incident', value: @incident.occurred_time
    row.text_field field: '# passengers on bus', value: report.passengers_onboard
    row.text_field field: '# courtesy cards distributed', value: report.courtesy_cards_distributed
    row.text_field field: '# courtesy cards attached', value: report.courtesy_cards_collected
    row.text_field field: 'Speed at time of incident', value: report.speed
  end

  pdf.field_row height: 20, units: 4 do |row|
    row.text_field width: 3, field: 'Location of Accident / Incident', value: report.location
    row.text_field field: 'Town', value: report.town
  end

  occurrence_types = [
    report.motor_vehicle_collision?,
    report.passenger_incident?,
    report.other?
  ]
  occurrence_types << occurrence_types.none?

  pdf.field_row height: 50, units: 12 do |row|
    row.check_box_field width: 2, field: 'Type of Occurrence',
      options: ['Collision', 'Passenger', 'Other'],
      checked: occurrence_types
    row.check_box_field width: 3, field: 'Weather Conditions',
      options: IncidentReport::WEATHER_OPTIONS,
      checked: IncidentReport::WEATHER_OPTIONS.map{|c| report.weather_conditions == c}
    row.check_box_field width: 3, field: 'Road Conditions',
      options: IncidentReport::ROAD_OPTIONS,
      checked: IncidentReport::ROAD_OPTIONS.map{|c| report.road_conditions == c}
    row.check_box_field width: 2, field: 'Light Conditions',
      options: IncidentReport::LIGHT_OPTIONS,
      checked: IncidentReport::LIGHT_OPTIONS.map{|c| report.light_conditions == c}
    row.text_field width: 2, field: 'Headlights on at time of incident?',
      value: yes_no(report.headlights_used?), options: { if: @incident.completed? }
  end

  pdf.bounding_box [0, pdf.cursor], width: pdf.bounds.width, height: 30 do
    pdf.move_down 15
    pdf.text 'Complete the following if collision'.upcase,
      align: :center, size: 14, style: :bold
  end

  pdf.field_row height: 30, units: 112 do |row|
    row.text_field width: 18, field: 'Plate # other vehicle', value: report.other_vehicle_plate
    row.text_field width: 7, field: 'State', value: report.other_vehicle_state
    row.text_field width: 13, field: 'Make', value: report.other_vehicle_make
    row.text_field width: 13, field: 'Model', value: report.other_vehicle_model
    row.text_field width: 10, field: 'Year', value: report.other_vehicle_year
    row.text_field width: 11, field: 'Color', value: report.other_vehicle_color
    row.text_field width: 14, field: '# of passengers in other vehicle', value: report.other_vehicle_passengers
    row.text_field width: 12, field: 'Direction of bus', value: report.direction
    row.text_field width: 14, field: 'Direction of other vehicle', value: report.other_vehicle_direction
  end

  owner_name = if report.other_vehicle_owned_by_other_driver?
                 'Owned by Driver'
                else report.other_vehicle_owner_name
               end
  pdf.field_row height: 20, units: 28 do |row|
    row.text_field width: 7, field: 'Name of other driver', value: report.other_driver_name
    row.text_field width: 5, field: "Driver's license #", value: report.other_driver_license_number
    row.text_field width: 2, field: 'State', value: report.other_driver_license_state
    row.text_field width: 14, field: 'Owner of other vehicle', value: owner_name
  end

  pdf.field_row height: 75, units: 28 do |row|
    row.text_field width: 9, field: 'Address of other driver', value: report.other_vehicle_driver_full_address,
      options: { valign: :center }
    row.text_field width: 5, height: 25, field: 'Home', value: report.other_vehicle_driver_home_phone
    row.text_field width: 14, height: 50, field: 'Address of owner', value: report.other_vehicle_owner_full_address,
      options: { unless: report.other_vehicle_owned_by_other_driver? }

    row.at_height 25, unit: 9 do
      row.text_field width: 5, height: 25, field: 'Cell', value: report.other_vehicle_driver_cell_phone
    end

    row.at_height 50, unit: 9 do
      row.text_field width: 5, height: 25, field: 'Work', value: report.other_vehicle_driver_work_phone
      row.text_field width: 2, height: 25, field: 'Police on scene?', value: yes_no(report.police_on_scene?),
        options: { if: report.motor_vehicle_collision? }
      row.text_field width: 4, height: 25, field: 'Badge #', value: report.police_badge_number
      row.text_field width: 4, height: 25, field: 'Town (or State)', value: report.police_town_or_state
      row.text_field width: 4, height: 25, field: 'Case # assigned', value: report.police_case_assigned
    end
  end

  pdf.field_row height: 50, units: 5 do |row|
    row.text_field field: 'Point of impact on bus', value: report.point_of_impact,
      options: { valign: :center }
    row.text_field width: 2, field: 'Describe damage to bus at point of impact',
      value: report.damage_to_bus_point_of_impact,
      options: { align: :left, valign: :top }
    row.text_field width: 2, field: 'Describe damage to other vehicle at point of impact',
      value: report.damage_to_other_vehicle_point_of_impact,
      options: { align: :left, valign: :top }
  end

  pdf.field_row height: 20, units: 28 do |row|
    row.text_field width: 14, field: 'Insurance carrier of other driver', value: report.insurance_carrier
    row.text_field width: 9, field: 'Insurance policy #', value: report.insurance_policy_number
    row.text_field width: 5, field: 'Policy effective date', value: report.insurance_effective_date.try(:strftime, '%m/%d/%Y')
  end

  pdf.bounding_box [0, pdf.cursor], width: pdf.bounds.width, height: 30 do
    pdf.move_down 15
    pdf.text "Complete the following if passenger incident".upcase,
      align: :center, size: 14, style: :bold
  end

  pdf.field_row height: 72, units: 22 do |row|
    row.check_box_field width: 7, field: 'Nature of incident (check all that apply)',
      options: IncidentReport::PASSENGER_INCIDENT_LOCATIONS,
      checked: report.occurred_location_matrix, per_column: 5
    row.check_box_field width: 3, field: 'Motion of bus',
      options: IncidentReport::BUS_MOTION_OPTIONS,
      checked: IncidentReport::BUS_MOTION_OPTIONS.map{|m| report.motion_of_bus == m },
      per_column: 4
    row.check_box_field width: 2, field: 'Condition of steps',
      options: IncidentReport::STEP_CONDITION_OPTIONS,
      checked: IncidentReport::STEP_CONDITION_OPTIONS.map{|c| report.condition_of_steps == c },
      per_column: 4
    row.text_field width: 2, height: 36, field: 'Bus kneeled?', value: yes_no(report.bus_kneeled?),
      options: { if: report.passenger_incident? }
    row.text_field width: 8, height: 36, field: 'If stopped, not up to curb, give reason', value: report.reason_not_up_to_curb
    row.at_height 36, unit: 12 do
      row.text_field width: 2, height: 36, field: 'Bus up to curb?', value: yes_no(report.bus_up_to_curb?),
        options: { if: report.passenger_incident? }
      row.text_field width: 8, height: 36, field: 'License # of vehicle in bus stop', value: report.vehicle_in_bus_stop_plate
    end
  end

  pdf.field_row height: 28, units: 28 do |row|
    row.text_field width: 4, field: 'Was passenger injured?', value: yes_no(report.passenger_injured?),
      options: { if: report.passenger_incident? }
    row.text_field width: 5, field: 'Name of injured passenger', value: report.injured_passenger[:name]
    row.text_field width: 14, field: 'Address', value: report.injured_passenger_full_address,
      options: { unless: report.injured_passenger.empty? }
    row.text_field width: 5, field: 'Phone', value: report.injured_passenger[:phone]
  end

  pdf.move_cursor_to 160

  description = if report.long_description?
                  '(Description on next page due to length)'
                else report.description
                end

  pdf.field_row height: 130, units: 1 do |row|
    row.text_field field: 'Describe the accident or incident in detail', value: description,
      options: { valign: :top, align: :left }
  end

  pdf.field_row height: 30, units: 28 do |row|
    row.text_field width: 9, field: "Operator's signature", value: ''
    row.text_field width: 5, field: 'Date of this report', value: Time.zone.now.strftime('%m/%d/%Y')
    row.text_field width: 9, field: "Recv'd by", value: ''
    row.text_field width: 5, field: "Date recv'd", value: ''
  end

  if report.long_description?
    
    pdf.start_new_page

    pdf.bounding_box [0, pdf.bounds.height], width: 380, height: 80 do
      pdf.move_down 5
      pdf.font 'Times-Roman', size: 30 do
        pdf.text 'SATCo / VATCo', align: :center
      end
      pdf.text 'Accident / Incident Narrative', size: 18, align: :center
    end
    pdf.bounding_box [380, pdf.bounds.height], width: 180, height: 80 do
      pdf.move_down 8
      pdf.bounds.add_left_padding 5
      ['File #', 'Code', 'Cause', 'Claim case #'].each do |field|
        pdf.text field
        pdf.move_down 4
      end
    end

    pdf.field_row height: 25, units: 8 do |row|
      row.text_field width: 4, field: 'Operator', value: report.user.proper_name
      row.text_field field: 'Badge No.', value: report.user.badge_number
      row.text_field field: 'Bus #', value: report.bus
      row.text_field width: 2, field: 'Date of Incident', value: @incident.occurred_at.try(:strftime, '%m/%d/%Y')
    end

    pdf.field_row height: pdf.cursor - 30, units: 1 do |row|
      row.text_field field: 'Describe the accident or incident in detail', value: report.description,
        options: { size: 12, valign: :top, align: :left }
    end

    pdf.move_cursor_to 30

    pdf.field_row height: 30, units: 28 do |row|
      row.text_field width: 9, field: "Operator's signature", value: ''
      row.text_field width: 5, field: 'Date of this report', value: Time.zone.now.strftime('%m/%d/%Y')
      row.text_field width: 9, field: "Recv'd by", value: ''
      row.text_field width: 5, field: "Date recv'd", value: ''
    end
  end

  pdf.start_new_page

  pdf.image Rails.root.join('app/assets/images/bus_diagram.png'),
    width: pdf.bounds.width, height: pdf.bounds.height
=end

  report = @incident.supervisor_incident_report

  pdf.start_new_page
  pdf.bounding_box [0, pdf.bounds.height], width: 380, height: 80 do
    pdf.move_down 5
    pdf.font 'Times-Roman', size: 30 do
      pdf.text 'SATCo / VATCo', align: :center
    end
    pdf.text 'Supervisor Incident / Accident Report', size: 18, align: :center
    pdf.text 'Fill in all applicable blanks. Be specific. Use black ink only.',
      align: :center, style: :bold
  end
  pdf.bounding_box [380, pdf.bounds.height], width: 180, height: 80 do
    pdf.move_down 8
    pdf.bounds.add_left_padding 5
    ['File #', 'Code', 'Cause', 'Claim case #'].each do |field|
      pdf.text field
      pdf.move_down 4
    end
  end

  pdf.field_row height: 25, units: 9 do |row|
    row.text_field width: 2, field: 'Supervisor', value: report.user.proper_name
    row.text_field field: 'Badge No.', value: report.user.badge_number
    row.text_field width: 2, field: 'Operator', value: @incident.driver.proper_name
    row.text_field field: 'Badge No.', value: @incident.driver.badge_number
    row.text_field field: 'Run #', value: report.run
    row.text_field field: 'Block #', value: report.block
    row.text_field field: 'Bus #', value: report.bus
  end
end
