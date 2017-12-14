$.fn.showIfChecked = (checkbox, selector, options) ->
  $(this).on 'change', checkbox, ->
    checked = $(this).is ':checked'
    if typeof(options) != 'undefined' && options.reverse
      checked = !checked
    if checked
      $(selector).slideDown()
    else $(selector).slideUp()

determineShouldProvideReasonNotUpToCurb = ->
  motion = $('#report_motion_of_bus').val()
  upToCurb = $('#report_bus_up_to_curb').is ':checked'
  formSection = $('.reason-not-up-to-curb-info')
  if motion == 'Stopped' && !upToCurb
    formSection.slideDown()
  else formSection.slideUp()

addFields = (fieldsSelector) ->
  fields = $(fieldsSelector).last()
  fields.clone().insertAfter fields
  $(fieldsSelector).last().find('input').val('').prop 'checked', false

addWitnessFields = (event) ->
  event.preventDefault()
  addFields '.witness-fields'

addInjuredPassengerFields = (event) ->
  event.preventDefault()
  addFields '.pax-fields'

toggleReasonsForTesting = ->
  reason = $('#report_reason_test_completed').val()
  switch reason
    when 'Post-Accident'
      $('.post-accident-info').slideDown()
      $('.reasonable-suspicion-info').slideUp()
    when 'Reasonable Suspicion'
      $('.post-accident-info').slideUp()
      $('.reasonable-suspicion-info').slideDown()
    when ''
      $('.post-accident-info').slideUp()
      $('.reasonable-suspicion-info').slideUp()

$(document).on 'turbolinks:load', ->
  $('form').showIfChecked '#report_motor_vehicle_collision',
                          '.motor-vehicle-collision-info'

  $('form').showIfChecked '#report_summons_or_warning_issued',
                          '.summons-info'

  $('form').showIfChecked '#report_police_on_scene',
                          '.police-info'

  $('form').showIfChecked '#report_other_vehicle_owned_by_other_driver',
                          '.other-vehicle-owner-info', reverse: true

  $('form').showIfChecked '#report_passenger_incident',
                          '.passenger-incident-info'

  $('form').on 'change', '#report_motion_of_bus',
               determineShouldProvideReasonNotUpToCurb

  $('form').on 'click', '#report_bus_up_to_curb',
               determineShouldProvideReasonNotUpToCurb

  $('form').showIfChecked '#report_pictures_saved',
                          '.saved-pictures-info'

  $('form').showIfChecked '#report_completed_drug_or_alcohol_test',
                          '.test-info'

  $('form').on 'change', '#report_reason_test_completed',
               toggleReasonsForTesting

  $('form').showIfChecked '#report_test_due_to_employee_appearance',
                          '.employee-appearance-info'

  $('form').showIfChecked '#report_test_due_to_employee_behavior',
                          '.employee-behavior-info'

  $('form').showIfChecked '#report_test_due_to_employee_speech',
                          '.employee-speech-info'

  $('form').showIfChecked '#report_test_due_to_employee_odor',
                          '.employee-odor-info'

  $('form').showIfChecked '#report_witness_info',
                          '.witness-info'

  $('form').showIfChecked '#report_inj_pax',
                          '.inj-pax-info'

  $('form').on 'click', 'button.add-witness', addWitnessFields

  $('form').on 'click', 'button.add-pax', addInjuredPassengerFields
