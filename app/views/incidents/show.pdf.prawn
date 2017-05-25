# PDF is 720 x 540

prawn_document do |pdf|
  pdf.instance_eval do
    def form_box(start, width:, height:, field:, value:)
      bounding_box start, width: width, height: height do
        stroke_bounds
        bounds.add_left_padding 2
        move_down 2
        text field.upcase, size: 6
        if value.present?
          move_down 2 + (height - 25)
          text value, align: :center
        end
      end
    end
  end

  pdf.start_new_page
  pdf.stroke_bounds
  pdf.bounding_box [0, 720], width: 360, height: 75 do
    pdf.stroke_bounds
    pdf.move_down 10
    pdf.font 'Times-Roman', size: 24 do
      pdf.text 'SATCo / VATCo', align: :center
    end
    pdf.text 'Operator Incident / Accident Report', align: :center
    pdf.text 'Fill in all applicable blanks. Be specific. Use black ink only.',
      align: :center
  end
  pdf.move_up 75
  pdf.bounding_box [360, 720], width: 180, height: 75 do
    pdf.stroke_bounds
    pdf.move_down 8
    pdf.bounds.add_left_padding 5
    ['File #', 'Code', 'Cause', 'Claim case #'].each do |field|
      pdf.text field
      pdf.move_down 3
    end
  end
  pdf.form_box [0, 645], width: 270, height: 25,
    field: 'Operator',
    value: @incident.driver.name
  pdf.form_box [270, 645], width: 60, height: 25,
    field: 'Badge No.',
    value: @incident.driver.badge_number
  pdf.form_box [330, 645], width: 70,  height: 25,
    field: 'Run #',
    value: @incident.run
  pdf.form_box [400, 645], width: 70,  height: 25,
    field: 'Block #',
    value: @incident.block
  pdf.form_box [470, 645], width: 70, height: 25,
    field: 'Bus #',
    value: @incident.bus

  pdf.form_box [0, 620], width: 90, height: 40,
    field: 'Date of Incident',
    value: @incident.occurred_at.strftime('%m/%d/%Y')
  pdf.form_box [90, 620], width: 90, height: 40,
    field: 'Time of Incident',
    value: @incident.occurred_time
  pdf.form_box [180, 620], width: 90, height: 40,
    field: '# passengers on bus',
    value: @incident.passengers_onboard
  pdf.form_box [270, 620], width: 90, height: 40,
    field: '# courtesy cards distributed',
    value: @incident.courtesy_cards_distributed
  pdf.form_box [360, 620], width: 90, height: 40,
    field: '# courtesy cards attached',
    value: @incident.courtesy_cards_collected
  pdf.form_box [450, 620], width: 90, height: 40,
    field: 'Speed at time of incident',
    value: @incident.speed
end
