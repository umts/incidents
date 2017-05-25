$.fn.showIfChecked = (checkbox, selector, options) ->
  $(this).on 'change', checkbox, () ->
    checked = $(this).is ':checked'
    if typeof(options) != 'undefined' && options.reverse
      checked = !checked
    if checked
      $(selector).show()
    else $(selector).hide()

determineShouldProvideReasonNotUpToCurb = () ->
  motion = $('#incident_motion_of_bus').val()
  upToCurb = $('#incident_bus_up_to_curb').is ':checked'
  formSection = $('.reason-not-up-to-curb-info')
  if motion == 'Stopped' && !upToCurb
    formSection.show()
  else formSection.hide()

$(document).ready ->
  $('form').showIfChecked '#incident_motor_vehicle_collision',
                          '.motor-vehicle-collision-info'

  $('form').showIfChecked '#incident_police_on_scene',
                          '.police-info'

  $('form').showIfChecked '#incident_other_vehicle_owned_by_other_driver',
                          '.other-vehicle-owner-info', reverse: true

  $('form').showIfChecked '#incident_passenger_incident',
                          '.passenger-incident-info'

  $('form').showIfChecked '#incident_passenger_injured',
                          '.injured-passenger-info'

  $('form').on 'change', '#incident_motion_of_bus',
               determineShouldProvideReasonNotUpToCurb

  $('form').on 'click', '#incident_bus_up_to_curb',
               determineShouldProvideReasonNotUpToCurb
