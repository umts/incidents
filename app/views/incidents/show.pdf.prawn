# PDF is 740 x 560

prawn_document do |pdf|
  pdf.instance_eval do
    def text_field(start, width:, height:, field:, value:, options: {})
      bounding_box start, width: width, height: height do
        stroke_bounds
        bounds.add_left_padding 2
        move_down 2
        text field.upcase, size: 6
        if value.present?
          if options[:bottom] == false
            move_down 5
          else move_cursor_to 12 # pt from bottom
          end
          unless options[:if] == false || options[:unless] == true
            align = options[:align] || :center
            value = Array(value)
            value.each do |line|
              text line, align: align
            end
          end
        end
      end
    end

    def check_box(checked:)
      # TODO
    end

    def check_box_field(start, width:, height:, field:, options:, checked:, per_column: 3)
      bounding_box start, width: width, height: height do
        stroke_bounds
        bounds.add_left_padding 2
        move_down 2
        text field.upcase, size: 6
        move_down 2
        box_height = cursor
        box_width = (width - 4) / options.each_slice(per_column).count
        options.each_slice(per_column).with_index do |opts, i|
          bounding_box [box_width * i, box_height], width: box_width, height: box_height do
            bounds.add_left_padding 2
            bounds.add_right_padding 2
            opts.each.with_index do |opt, j|
              check_box checked: checked[j]
              text opt, size: 10
              move_down 2
            end
          end
        end
      end
    end
  end


  pdf.start_new_page
  pdf.bounding_box [0, 740], width: 380, height: 80 do
    pdf.move_down 10
    pdf.font 'Times-Roman', size: 30 do
      pdf.text 'SATCo / VATCo', align: :center
    end
    pdf.text 'Operator Incident / Accident Report', size: 18, align: :center
    pdf.text 'Fill in all applicable blanks. Be specific. Use black ink only.',
      align: :center, style: :bold
  end
  pdf.move_up 75
  pdf.bounding_box [380, 740], width: 180, height: 80 do
    pdf.move_down 8
    pdf.bounds.add_left_padding 5
    ['File #', 'Code', 'Cause', 'Claim case #'].each do |field|
      pdf.text field
      pdf.move_down 4
    end
  end
  pdf.text_field [0, 660], width: 270, height: 25,
    field: 'Operator',
    value: @incident.driver.name
  pdf.text_field [270, 660], width: 72, height: 25,
    field: 'Badge No.',
    value: @incident.driver.badge_number
  pdf.text_field [342, 660], width: 73,  height: 25,
    field: 'Run #',
    value: @incident.run
  pdf.text_field [415, 660], width: 72,  height: 25,
    field: 'Block #',
    value: @incident.block
  pdf.text_field [487, 660], width: 73, height: 25,
    field: 'Bus #',
    value: @incident.bus

  pdf.text_field [0, 635], width: 93, height: 25,
    field: 'Date of Incident',
    value: @incident.occurred_at.strftime('%m/%d/%Y')
  pdf.text_field [93, 635], width: 93, height: 25,
    field: 'Time of Incident',
    value: @incident.occurred_time
  pdf.text_field [186, 635], width: 94, height: 25,
    field: '# passengers on bus',
    value: @incident.passengers_onboard
  pdf.text_field [280, 635], width: 93, height: 25,
    field: '# courtesy cards distributed',
    value: @incident.courtesy_cards_distributed
  pdf.text_field [373, 635], width: 93, height: 25,
    field: '# courtesy cards attached',
    value: @incident.courtesy_cards_collected
  pdf.text_field [466, 635], width: 94, height: 25,
    field: 'Speed at time of incident',
    value: @incident.speed

  pdf.text_field [0, 610], width: 440, height: 25,
    field: 'Location of Accident / Incident',
    value: @incident.location
  pdf.text_field [440, 610], width: 120, height: 25,
    field: 'Town',
    value: @incident.town

  occurrence_types = [
    @incident.motor_vehicle_collision?,
    @incident.passenger_incident?,
    @incident.other?
  ]
  occurrence_types << occurrence_types.none?
  pdf.check_box_field [0, 585], width: 87, height: 50,
    field: 'Type of Occurrence', options: ['Collision', 'Passenger', 'Other'],
    checked: occurrence_types
  pdf.check_box_field [87, 585], width: 150, height: 50,
    field: 'Weather Conditions', options: Incident::WEATHER_OPTIONS,
    checked: Incident::WEATHER_OPTIONS.map{|c| @incident.weather_conditions == c}
  pdf.check_box_field [237, 585], width: 150, height: 50,
    field: 'Road Conditions', options: Incident::ROAD_OPTIONS,
    checked: Incident::ROAD_OPTIONS.map{|c| @incident.road_conditions == c}
  pdf.check_box_field [387, 585], width: 87, height: 50,
    field: 'Light Conditions', options: Incident::LIGHT_OPTIONS,
    checked: Incident::LIGHT_OPTIONS.map{|c| @incident.light_conditions == c}
  pdf.text_field [474, 585], width: 86, height: 50,
    field: 'Headlights on at time of incident?',
    value: yes_no(@incident.headlights_used?)

  pdf.bounding_box [0, 535], width: pdf.bounds.width, height: 25 do
    pdf.move_down 12
    pdf.text "Complete the following if collision".upcase,
      align: :center, size: 14, style: :bold
  end

  pdf.text_field [0, 510], width: 90, height: 25,
    field: 'Plate # other vehicle',
    value: @incident.other_vehicle_plate
  pdf.text_field [90, 510], width: 40, height: 25,
    field: 'State',
    value: @incident.other_vehicle_state
  pdf.text_field [130, 510], width: 65, height: 25,
    field: 'Make',
    value: @incident.other_vehicle_make
  pdf.text_field [195, 510], width: 65, height: 25,
    field: 'Model',
    value: @incident.other_vehicle_model
  pdf.text_field [260, 510], width: 55, height: 25,
    field: 'Year',
    value: @incident.other_vehicle_year
  pdf.text_field [315, 510], width: 55, height: 25,
    field: 'Color',
    value: @incident.other_vehicle_color
  pdf.text_field [370, 510], width: 60, height: 25,
    field: '# of passengers in other vehicle',
    value: @incident.other_vehicle_passengers
  pdf.text_field [430, 510], width: 60, height: 25,
    field: 'Direction of bus',
    value: @incident.direction
  pdf.text_field [490, 510], width: 70, height: 25,
    field: 'Direction of other vehicle',
    value: @incident.other_vehicle_direction

  pdf.text_field [0, 485], width: 140, height: 25,
    field: 'Name of other driver',
    value: @incident.other_driver_name
  pdf.text_field [140, 485], width: 100, height: 25,
    field: "Driver's license #",
    value: @incident.other_driver_license_number
  pdf.text_field [240, 485], width: 40, height: 25,
    field: 'State',
    value: @incident.other_driver_license_state
  owner_name = if @incident.other_vehicle_owned_by_other_driver?
                 'Owned by Driver'
                else @incident.other_vehicle_owner_name
               end
  pdf.text_field [280, 485], width: 280, height: 25,
    field: 'Owner of other vehicle',
    value: owner_name

  pdf.text_field [0, 460], width: 180, height: 75,
    field: 'Address of other driver',
    value: @incident.other_vehicle_driver_full_address,
    options: { bottom: false }
  pdf.text_field [180, 460], width: 100, height: 25,
    field: 'Home',
    value: @incident.other_vehicle_driver_home_phone
  pdf.text_field [180, 435], width: 100, height: 25,
    field: 'Cell',
    value: @incident.other_vehicle_driver_cell_phone
  pdf.text_field [180, 410], width: 100, height: 25,
    field: 'Work',
    value: @incident.other_vehicle_driver_work_phone

  pdf.text_field [280, 460], width: 280, height: 50,
    field: 'Address of owner',
    value: @incident.other_vehicle_owner_full_address,
    options: { unless: @incident.other_vehicle_owned_by_other_driver? }
  pdf.text_field [280, 410], width: 40, height: 25,
    field: 'Police on scene?',
    value: yes_no(@incident.police_on_scene?)
  pdf.text_field [320, 410], width: 80, height: 25,
    field: 'Badge #',
    value: @incident.police_badge_number
  pdf.text_field [400, 410], width: 80, height: 25,
    field: 'Town (or State)',
    value: @incident.police_town_or_state
  pdf.text_field [480, 410], width: 80, height: 25,
    field: 'Case # assigned',
    value: @incident.police_case_assigned

  pdf.text_field [0, 385], width: 280, height: 50,
    field: 'Describe damage to bus at point of impact',
    value: @incident.damage_to_bus_point_of_impact,
    options: { align: :left, bottom: false }
  pdf.text_field [280, 385], width: 280, height: 50,
    field: 'Describe damage to other vehicle at point of impact',
    value: @incident.damage_to_other_vehicle_point_of_impact,
    options: { align: :left, bottom: false }

  pdf.text_field [0, 335], width: 280, height: 25,
    field: 'Insurance carrier of other driver',
    value: @incident.insurance_carrier
  pdf.text_field [280, 335], width: 180, height: 25,
    field: 'Insurance policy #',
    value: @incident.insurance_policy_number
  pdf.text_field [460, 335], width: 100, height: 25,
    field: 'Policy effective date',
    value: @incident.insurance_effective_date

  pdf.bounding_box [0, 310], width: pdf.bounds.width, height: 25 do
    pdf.move_down 12
    pdf.text "Complete the following if passenger incident".upcase,
      align: :center, size: 14, style: :bold
  end

  # TODO
  pdf.check_box_field [0, 285], width: 150, height: 80,
    field: 'Nature of incident (check all that apply)',
    options: ['TODO'] * 10,
    checked: [], per_column: 5
  pdf.check_box_field [150, 285], width: 70, height: 80,
    field: 'Motion of bus',
    options: Incident::BUS_MOTION_OPTIONS,
    checked: Incident::BUS_MOTION_OPTIONS.map{|m| @incident.motion_of_bus == m },
    per_column: 4
  pdf.check_box_field [220, 285], width: 60, height: 80,
    field: 'Condition of steps',
    options: Incident::STEP_CONDITION_OPTIONS,
    checked: Incident::STEP_CONDITION_OPTIONS.map{|c| @incident.condition_of_steps == c },
    per_column: 4
  pdf.text_field [280, 285], width: 40, height: 40,
    field: 'Bus kneeled?',
    value: yes_no(@incident.bus_kneeled?)
  pdf.text_field [280, 245], width: 40, height: 40,
    field: 'Bus up to curb?',
    value: yes_no(@incident.bus_up_to_curb?)
  pdf.text_field [320, 285], width: 240, height: 40,
    field: 'If stopped, not up to curb, give reason',
    value: @incident.reason_not_up_to_curb
  pdf.text_field [320, 245], width: 240, height: 40,
    field: 'License # of vehicle in bus stop',
    value: @incident.vehicle_in_bus_stop_plate

  pdf.text_field [0, 205], width: 80, height: 25,
    field: 'Was passenger injured?',
    value: yes_no(@incident.passenger_injured?)
  pdf.text_field [80, 205], width: 100, height: 25,
    field: 'Name of injured passenger',
    value: @incident.injured_passenger[:name]
  pdf.text_field [180, 205], width: 280, height: 25,
    field: 'Address',
    value: @incident.injured_passenger_full_address,
    options: { unless: @incident.injured_passenger.empty? }
  pdf.text_field [460, 205], width: 100, height: 25,
    field: 'Phone',
    value: @incident.injured_passenger[:phone]

  pdf.text_field [0, 180], width: 560, height: 130,
    field: 'Describe the accident or incident in detail',
    value: @incident.description,
    options: { bottom: false, align: :left }
  
  pdf.text_field [0, 30], width: 180, height: 30,
    field: "Operator's signature", value: ''
  pdf.text_field [180, 30], width: 100, height: 30,
    field: 'Date of this report',
    value: @incident.occurred_at.strftime('%m/%d/%Y')
  pdf.text_field [280, 30], width: 180, height: 30,
    field: "Recv'd by", value: ''
  pdf.text_field [460, 30], width: 100, height: 30,
    field: "Date recv'd", value: ''
end
