# PDF is 740 x 560

prawn_document do |pdf|
  pdf.instance_eval do
    def text_field(start, width:, height:, field:, value:, except_if: false)
      bounding_box start, width: width, height: height do
        stroke_bounds
        bounds.add_left_padding 2
        move_down 2
        text field.upcase, size: 6
        if value.present?
          move_cursor_to 12 # pt from bottom
          unless except_if == true
            text value, align: :center
          end
        end
      end
    end

    def check_box(checked:)
      # TODO
    end

    def check_box_field(start, width:, height:, field:, options:, checked:)
      bounding_box start, width: width, height: height do
        stroke_bounds
        bounds.add_left_padding 2
        move_down 2
        text field.upcase, size: 6
        move_down 2
        box_height = cursor
        box_width = (width - 4) / options.each_slice(3).count
        options.each_slice(3).with_index do |opts, i|
          bounding_box [box_width * i, box_height], width: box_width, height: box_height do
            # stroke_bounds # TODO remove
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
  pdf.stroke_bounds
  pdf.bounding_box [0, 740], width: 380, height: 80 do
    pdf.stroke_bounds
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
    pdf.stroke_bounds
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

  pdf.bounding_box [0, 535], width: pdf.bounds.width, height: 15 do
    pdf.stroke_bounds
    pdf.move_down 2
    pdf.text "Complete the following if collision".upcase,
      align: :center, size: 14, style: :bold
  end

  pdf.text_field [0, 520], width: 90, height: 25,
    field: 'Plate # other vehicle',
    value: @incident.other_vehicle_plate
  pdf.text_field [90, 520], width: 40, height: 25,
    field: 'State',
    value: @incident.other_vehicle_state
  pdf.text_field [130, 520], width: 65, height: 25,
    field: 'Make',
    value: @incident.other_vehicle_make
  pdf.text_field [195, 520], width: 65, height: 25,
    field: 'Model',
    value: @incident.other_vehicle_model
  pdf.text_field [260, 520], width: 55, height: 25,
    field: 'Year',
    value: @incident.other_vehicle_year
  pdf.text_field [315, 520], width: 55, height: 25,
    field: 'Color',
    value: @incident.other_vehicle_color
  pdf.text_field [370, 520], width: 60, height: 25,
    field: '# of passengers in other vehicle',
    value: @incident.other_vehicle_passengers
  pdf.text_field [430, 520], width: 60, height: 25,
    field: 'Direction of bus',
    value: @incident.direction
  pdf.text_field [490, 520], width: 70, height: 25,
    field: 'Direction of other vehicle',
    value: @incident.other_vehicle_direction

  pdf.text_field [0, 495], width: 140, height: 25,
    field: 'Name of other driver',
    value: @incident.other_driver_name
  pdf.text_field [140, 495], width: 100, height: 25,
    field: "Driver's license #",
    value: @incident.other_driver_license_number
  pdf.text_field [240, 495], width: 40, height: 25,
    field: 'State',
    value: @incident.other_driver_license_state
  owner_name = if @incident.other_vehicle_owned_by_other_driver?
                 'Owned by Driver'
                else @incident.other_vehicle_owner_name
               end
  pdf.text_field [280, 495], width: 280, height: 25,
    field: 'Owner of other vehicle',
    value: owner_name

  # TODO
  pdf.text_field [0, 470], width: 180, height: 75,
    field: 'Address of other driver',
    value: ''
  pdf.text_field [180, 470], width: 100, height: 25,
    field: 'Home',
    value: @incident.other_vehicle_driver_home_phone
  pdf.text_field [180, 445], width: 100, height: 25,
    field: 'Cell',
    value: @incident.other_vehicle_driver_cell_phone
  pdf.text_field [180, 420], width: 100, height: 25,
    field: 'Work',
    value: @incident.other_vehicle_driver_work_phone

  owner_address = ''
  # TODO
  unless @incident.other_vehicle_owned_by_other_driver?
  end
  pdf.text_field [280, 470], width: 280, height: 50,
    field: 'Address of owner',
    value: owner_address,
    except_if: @incident.other_vehicle_owned_by_other_driver?
  pdf.text_field [280, 420], width: 40, height: 25,
    field: 'Police on scene?',
    value: yes_no(@incident.police_on_scene?)
  pdf.text_field [320, 420], width: 80, height: 25,
    field: 'Badge #',
    value: @incident.police_badge_number
  pdf.text_field [400, 420], width: 80, height: 25,
    field: 'Town (or State)',
    value: @incident.police_town_or_state
  pdf.text_field [480, 420], width: 80, height: 25,
    field: 'Case # assigned',
    value: @incident.police_case_assigned

  pdf.text_field [0, 395], width: 280, height: 50,
    field: 'Describe damage to bus at point of impact',
    value: @incident.damage_to_bus_point_of_impact
  pdf.text_field [280, 395], width: 280, height: 50,
    field: 'Describe damage to other vehicle at point of impact',
    value: @incident.damage_to_other_vehicle_point_of_impact

  pdf.text_field [0, 345], width: 280, height: 25,
    field: 'Insurance carrier of other driver',
    value: @incident.insurance_carrier
  pdf.text_field [280, 345], width: 180, height: 25,
    field: 'Insurance policy #',
    value: @incident.insurance_policy_number
  pdf.text_field [460, 345], width: 100, height: 25,
    field: 'Policy effective date',
    value: @incident.insurance_effective_date

  pdf.bounding_box [0, 320], width: pdf.bounds.width, height: 15 do
    pdf.stroke_bounds
    pdf.move_down 2
    pdf.text "Complete the following if passenger incident".upcase,
      align: :center, size: 14, style: :bold
  end
end
