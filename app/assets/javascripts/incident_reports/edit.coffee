$.fn.showIfChecked = (checkbox, selector, options) ->
  $(this).on 'change', checkbox, ->
    checked = $(this).is ':checked'
    if typeof(options) != 'undefined' && options.reverse
      checked = !checked
    if checked
      $(selector).slideDown()
    else $(selector).slideUp()

determineShouldProvideReasonNotUpToCurb = ->
  motion = $('#incident_report_motion_of_bus').val()
  upToCurb = $('#incident_report_bus_up_to_curb').is ':checked'
  formSection = $('.reason-not-up-to-curb-info')
  if motion == 'Stopped' && !upToCurb
    formSection.slideDown()
  else formSection.slideUp()

incrementAttrs = (attrs) ->
  num = parseInt(attrs.name.match /\d+/) + 1
  if attrs.id != null
    attrs.id = attrs.id.replace /\d+/, num
  attrs.name = attrs.name.replace /\d+/, num

addFields = (fieldsSelector) ->
  fields = $(fieldsSelector).last()
  field = fields.clone()
  for attrs in field.find('input')
    incrementAttrs attrs
  field.insertAfter fields
  $(fieldsSelector).last().find('input').val('').prop 'checked', false

addWitnessFields = (event) ->
  event.preventDefault()
  addFields '.witness-fields'

addInjuredPassengerFields = (event) ->
  event.preventDefault()
  addFields '.pax-fields'

deleteFields = (fieldsSelector, fieldsCheckbox) ->
  fields = $(fieldsSelector).last()
  fields.find('input').val('').prop 'checked', false
  if $(fieldsSelector).length == 1
    $(fieldsCheckbox).prop 'checked', false
  if $(fieldsSelector).length > 1
    fields.remove()

deleteWitnessFields = (event) ->
  event.preventDefault()
  deleteFields '.witness-fields', '#supervisor_report_witness_info'

deleteInjuredPassengerFields = (event) ->
  event.preventDefault()
  deleteFields '.pax-fields', '#supervisor_report_inj_pax_info'

toggleReasonsForTesting = ->
  reason = $('#supervisor_report_test_status').val()
  if reason.includes('Reasonable Suspicion')
    $('.post-accident-info').slideUp()
    $('.reasonable-suspicion-info').slideDown()
    $('.driver-discounted-info').slideUp()
    $('.fta-threshold-info').slideUp()

  else if reason.includes('Threshold met (completed drug test)')
    $('.driver-discounted-info').slideUp()
    $('.reasonable-suspicion-info').slideUp()
    $('.fta-threshold-info').slideUp()
    $('.post-accident-info').slideDown()

  else if reason.includes('No threshold met')
    $('.driver-discounted-info').slideUp()
    $('.fta-threshold-info').slideDown()
    $('.post-accident-info').slideUp()
    $('.reasonable-suspicion-info').slideUp()

  else if reason.includes('discounted')
    $('.driver-discounted-info').slideDown()
    $('.fta-threshold-info').slideUp()
    $('.post-accident-info').slideUp()
    $('.reasonable-suspicion-info').slideUp()

  else
    $('.driver-discounted-info').slideUp()
    $('.fta-threshold-info').slideUp()
    $('.post-accident-info').slideUp()
    $('.reasonable-suspicion-info').slideUp()

$(document).on 'turbolinks:load', ->
  $('form').showIfChecked '#incident_report_motor_vehicle_collision',
                          '.motor-vehicle-collision-info'

  $('form').showIfChecked '#incident_report_summons_or_warning_issued',
                          '.summons-info'

  $('form').showIfChecked '#incident_report_police_on_scene',
                          '.police-info'

  $('form').showIfChecked '#incident_report_other_vehicle_owned_by_other_driver',
                          '.other-vehicle-owner-info', reverse: true

  $('form').showIfChecked '#incident_report_passenger_incident',
                          '.passenger-incident-info'

  $('form').on 'change', '#incident_report_motion_of_bus',
               determineShouldProvideReasonNotUpToCurb

  $('form').on 'click', '#incident_report_bus_up_to_curb',
               determineShouldProvideReasonNotUpToCurb

  $('form').showIfChecked '#supervisor_report_pictures_saved',
                          '.saved-pictures-info'

  $('form').showIfChecked '#supervisor_report_completed_drug_or_alcohol_test',
                          '.test-info'

  $('form').showIfChecked '#supervisor_report_completed_drug_or_alcohol_test',
                          '.no-test-info', reverse: true

  $('form').showIfChecked '#supervisor_report_fta_threshold_not_met',
                          '.fta-threshold-info'

  $('form').showIfChecked '#supervisor_report_driver_discounted',
                          '.driver-discounted-info'

  $('form').on 'change', '#supervisor_report_test_status',
               toggleReasonsForTesting

  $('form').showIfChecked '#supervisor_report_test_due_to_employee_appearance',
                          '.employee-appearance-info'

  $('form').showIfChecked '#supervisor_report_test_due_to_employee_behavior',
                          '.employee-behavior-info'

  $('form').showIfChecked '#supervisor_report_test_due_to_employee_speech',
                          '.employee-speech-info'

  $('form').showIfChecked '#supervisor_report_test_due_to_employee_odor',
                          '.employee-odor-info'

  $('form').showIfChecked '#supervisor_report_witness_info',
                          '.witness-info'

  $('form').showIfChecked '#supervisor_report_inj_pax_info',
                          '.inj-pax-info'

  $('form').on 'click', 'button.add-witness', addWitnessFields

  $('form').on 'click', 'button.add-pax', addInjuredPassengerFields
  
  $('form').on 'click', 'button.delete-witness', deleteWitnessFields

  $('form').on 'click', 'button.delete-pax', deleteInjuredPassengerFields
