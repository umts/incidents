# PDF is 740 x 560

prawn_document do |pdf|
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

  if report.motor_vehicle_collision?
    pdf.start_new_page

    pdf.image Rails.root.join('app/assets/images/bus_diagram.png'),
      width: pdf.bounds.width, height: pdf.bounds.height
  end

  if @incident.supervisor.present?

    report = @incident.supervisor_incident_report
    sup_report = @incident.supervisor_report

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

    pdf.field_row height: 30, units: 7 do |row|
      row.text_field field: 'Date of Incident', value: @incident.occurred_at.try(:strftime, '%m/%d/%Y')
      row.text_field field: 'Time of Incident', value: @incident.occurred_time
      row.text_field field: '# passengers on bus', value: report.passengers_onboard
      row.text_field field: '# courtesy cards distributed', value: report.courtesy_cards_distributed
      row.text_field field: '# courtesy cards attached', value: report.courtesy_cards_collected
      row.text_field field: '# photos taken', value: sup_report.saved_pictures
      row.text_field field: 'Credentials exchanged?', value: yes_no(report.credentials_exchanged?)
    end

    pdf.field_row height: 25, units: 5 do |row|
      row.text_field field: 'Location of Accident / Incident', value: report.location
      row.text_field field: 'Town', value: report.town
      row.text_field field: 'Posted speed limit (mph)', value: report.posted_speed_limit
      row.text_field field: 'Speed at time of incident', value: report.speed
      row.text_field field: 'Direction of bus', value: report.direction
    end

    pdf.field_row height: 90, units: 7 do |row|
      row.check_box_field field: 'Weather Conditions',
        options: IncidentReport::WEATHER_OPTIONS,
        checked: IncidentReport::WEATHER_OPTIONS.map{|c| report.weather_conditions == c},
        per_column: 5
      row.check_box_field field: 'Road Conditions',
        options: IncidentReport::ROAD_OPTIONS,
        checked: IncidentReport::ROAD_OPTIONS.map{|c| report.road_conditions == c},
        per_column: 5
      row.check_box_field field: 'Light Conditions',
        options: IncidentReport::LIGHT_OPTIONS,
        checked: IncidentReport::LIGHT_OPTIONS.map{|c| report.light_conditions == c}
      row.text_field field: 'Bus headlights used?',
        value: yes_no(report.headlights_used), options: { if: @incident.completed?, valign: :center }
      row.check_box_field field: 'Surface Type',
        options: IncidentReport::SURFACE_TYPE_OPTIONS,
        checked: IncidentReport::SURFACE_TYPE_OPTIONS.map{|c| report.surface_type == c},
        per_column: 6
      row.check_box_field field: 'Surface Grade', width: 2,
        options: IncidentReport::SURFACE_GRADE_OPTIONS,
        checked: IncidentReport::SURFACE_GRADE_OPTIONS.map{|c| report.surface_grade == c},
        per_column: 5
    end

    pdf.field_row height: 25, units: 4 do |row|
      row.text_field field: 'Police on scene?', value: yes_no(report.police_on_scene?),
        options: { if: report.motor_vehicle_collision? }
      row.text_field field: 'Badge #', value: report.police_badge_number
      row.text_field field: 'Town (or State)', value: report.police_town_or_state
      row.text_field field: 'Case # assigned', value: report.police_case_assigned
    end

    pdf.field_row height: 25, units: 5 do |row|
      row.text_field field: 'Summons or warning issued?',
        value: yes_no(report.summons_or_warning_issued?)
      row.text_field field: 'If yes, issued to whom? What is the charge?', width: 4,
        value: report.summons_or_warning_info

    end

    pdf.bounding_box [0, pdf.cursor], width: pdf.bounds.width, height: 30 do
      pdf.move_down 15
      pdf.text 'Complete the following if collision'.upcase,
        align: :center, size: 14, style: :bold
    end

    pdf.field_row height: 25, units: 7 do |row|
      row.text_field field: 'Plate # other vehicle', value: report.other_vehicle_plate
      row.text_field field: 'State', value: report.other_vehicle_state
      row.text_field field: 'Make', value: report.other_vehicle_make
      row.text_field field: 'Model', value: report.other_vehicle_model
      row.text_field field: 'Year', value: report.other_vehicle_year
      row.text_field field: '# of passengers', value: report.other_vehicle_passengers
      row.text_field field: 'Direction', value: report.other_vehicle_direction
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
        row.text_field width: 7, height: 25, field: 'Insurance carrier', value: report.insurance_carrier
        row.text_field width: 7, height: 25, field: 'Policy #', value: report.insurance_policy_number
      end
    end

    pdf.field_row height: 40, units: 5 do |row|
      row.text_field field: 'Point of impact on bus', value: report.point_of_impact,
        options: { valign: :center }
      row.text_field width: 2, field: 'Describe damage to bus at point of impact',
        value: report.damage_to_bus_point_of_impact,
        options: { align: :left, valign: :top }
      row.text_field width: 2, field: 'Describe damage to other vehicle at point of impact',
        value: report.damage_to_other_vehicle_point_of_impact,
        options: { align: :left, valign: :top }
    end

    pdf.bounding_box [0, pdf.cursor], width: pdf.bounds.width, height: 30 do
      pdf.move_down 15
      pdf.text 'Complete the following if passenger incident'.upcase,
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
        row.text_field width: 2, height: 36, field: 'Distance from curb', value: report.bus_distance_from_curb
        row.text_field width: 8, height: 36, field: 'License # of vehicle in bus stop', value: report.vehicle_in_bus_stop_plate
      end
    end

    if sup_report.witnesses.present?
      pdf.bounding_box [0, pdf.cursor], width: pdf.bounds.width, height: 30 do
        pdf.move_down 15
        pdf.text 'Witness Information'.upcase,
          align: :center, size: 14, style: :bold
      end
      sup_report.witnesses.each.with_index(1) do |witness, index|
        pdf.text "#{index}. #{witness.display_info}", size: 10
      end
    end

    # TODO injured passengers

    if report.motor_vehicle_collision?
      pdf.start_new_page

      pdf.image Rails.root.join('app/assets/images/bus_diagram.png'),
        width: pdf.bounds.width, height: pdf.bounds.height
    end

    pdf.start_new_page
    pdf.move_down 40
    pdf.field_row height: 25, units: 6 do |row|
      row.text_field field: 'Hard drive pulled?', value: yes_no(sup_report.hard_drive_pulled?)
      row.text_field field: 'Drive pulled', value: sup_report.hard_drive_removed
      row.text_field field: 'Pulled at', width: 2,
        value: sup_report.hard_drive_pulled_at.try(:strftime, '%A, %B %e, %l:%M %P')
      row.text_field field: 'Drive replaced with', value: sup_report.hard_drive_replaced
      pictures = sup_report.pictures_saved? ? sup_report.saved_pictures : 'None'
      row.text_field field: 'Pictures taken', value: pictures
    end

    pdf.field_row height: 130, units: 1 do |row|
      row.text_field field: 'Passenger statement and/or injury information in detail',
        value: sup_report.passenger_statement, options: { valign: :top, align: :left }
    end

    pdf.field_row height: 130, units: 1 do |row|
      row.text_field field: 'Statement of involved person(s)', value: report.description,
        options: { valign: :top, align: :left }
    end

    pdf.bounding_box [0, pdf.cursor], width: pdf.bounds.width, height: 30 do
      pdf.move_down 15
      pdf.text 'Drug & Alcohol Testing'.upcase,
        align: :center, size: 14, style: :bold
    end

    pdf.field_row height: 40, units: 8 do |row|
      row.check_box_field field: 'Testing scenario', width: 2,
        options: SupervisorReport::REASONS_FOR_TEST,
        checked: SupervisorReport::REASONS_FOR_TEST.select{ |c| sup_report.reason_test_completed == c }
      row.text_field field: 'Employee', width: 1,
        value: @incident.driver.proper_name,
        options: { valign: :center }
      row.text_field field: 'Date and time of incident', width: 2,
        value: @incident.occurred_at.try(:strftime, '%B %e, %Y %-l:%M %P'),
        options: { valign: :center }
      row.text_field field: 'Location of incident', width: 1,
        value: report.location,
        options: { valign: :center }
      row.text_field field: 'Testing location', width: 2,
        value: sup_report.testing_facility,
        options: { valign: :center }
    end

    pdf.move_down 15
    pdf.bounding_box [0, pdf.cursor], width: pdf.bounds.width, height: 50 do
      pdf.text 'Sequence of events:', style: :bold
      column_width  = pdf.bounds.width / 3
      sup_report.timeline.each_slice(4).with_index do |events, i|
        pdf.bounding_box [column_width * i, pdf.cursor], width: column_width do
          pdf.text_box events.join("\n"), size: 10
        end
      end
    end

    pdf.bounding_box [0, pdf.cursor], width: pdf.bounds.width, height: 30 do
      pdf.move_down 15
      pdf.text 'Complete the following if reasonable suspicion test'.upcase,
        align: :center, size: 14, style: :bold
    end

    pdf.field_row height: 25, units: 4 do |row|
      row.text_field field: 'Test conducted?', value: yes_no(sup_report.completed_drug_or_alcohol_test)
      test_types = []
      test_types << 'Drug' if sup_report.completed_drug_test?
      test_types << 'Alcohol' if sup_report.completed_alcohol_test?
      row.text_field field: 'Type of test', value: test_types.join(' & ')
      row.text_field field: 'Time of observation', value: sup_report.observation_made_at.try(:strftime, '%l:%M %P')
      test_reasons = []
      test_reasons << 'Appearance' if sup_report.test_due_to_employee_appearance?
      test_reasons << 'Behavior' if sup_report.test_due_to_employee_behavior?
      test_reasons << 'Odor' if sup_report.test_due_to_employee_odor?
      test_reasons << 'Speech' if sup_report.test_due_to_employee_speech?
      row.text_field field: 'Reason for conducting test', value: test_reasons.join('/')
    end

    pdf.field_row height: 25, units: 4 do |row|
      row.text_field field: 'Details of appearance', value: sup_report.employee_appearance
      row.text_field field: 'Details of behavior', value: sup_report.employee_behavior
      row.text_field field: 'Details of odor', value: sup_report.employee_odor
      row.text_field field: 'Details of speech', value: sup_report.employee_speech
    end

    pdf.bounding_box [0, pdf.cursor], width: pdf.bounds.width, height: 30 do
      pdf.move_down 15
      pdf.text 'Complete the following if post-accident test'.upcase,
        align: :center, size: 14, style: :bold
    end

    pdf.field_row height: 60, units: 1 do |row|
      reasons = [
        'BODILY INJURY - requiring immediate medical treatment away from the scene',
        'DISABLING DAMAGE - see note below for definition',
        'FATALITY - DOT testing is mandatory, no exceptions',
        'NOT CONDUCTED - I can completely discount the operator as a contributing factor to the accident.'
      ]
      checked_reasons = [
        sup_report.test_due_to_bodily_injury?,
        sup_report.test_due_to_disabling_damage?,
        sup_report.test_due_to_fatality?,
        sup_report.test_not_conducted?
      ]
      row.check_box_field field: 'Reason for test',
        options: reasons, checked: checked_reasons, per_column: 4
    end

    pdf.bounding_box [0, pdf.cursor], width: pdf.bounds.width, height: 40 do
      pdf.move_down 3
      pdf.text <<~DESCRIPTION.tr("\n", ' '), size: 8
        Disabling damage: damage that precludes the departure of any vehicle from
        the scene of an accident in its usual manner in daylight hours after
        simple repairs. Disabling damage includes: damage to vehicles that could
        have been operated, but would have caused further damage if so operated.
        Disabling damage does not include: damage that could be remedied
        temporarily at the scene of the occurrence without special tools or parts,
        tire disablement without other damage even if no spare tire is available,
        or damage to headlights, taillights, turn signals, horn, or windshield
        wipers that makes them inoperable.
      DESCRIPTION
    end
    
    pdf.move_down 50

    pdf.field_row height: 25, units: 3 do |row|
      row.text_field width: 1, field: "Supervisor's signature", value: ''
    end

    if sup_report.amplifying_comments.present?
      pdf.start_new_page
      pdf.bounding_box [0, pdf.cursor], width: pdf.bounds.width, height: 30 do
        pdf.move_down 15
        pdf.text 'Amplifying Comments'.upcase,
          align: :center, size: 14, style: :bold
      end
      pdf.bounding_box [0, pdf.cursor], width: pdf.bounds.width, height: 30 do
        pdf.move_down 3
        pdf.text <<~DESCRIPTION.tr("\n", ' '), size: 10
          Complete this section to note any problem or unusual circumstance
          associated with the testing process, any delay in testing beyond two
          hours of notifying employee of a testing requirement, or to provide
          additional information, if needed.
        DESCRIPTION
      end
      pdf.field_row height: 300, units: 1 do |row|
        row.text_field field: 'Amplifying comments', value: sup_report.amplifying_comments,
          options: { valign: :top, align: :left }
      end
    end
  end
end
