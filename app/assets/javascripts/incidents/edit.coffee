$.fn.showIfChecked = (checkbox, selector, options) ->
  $(this).on 'change', checkbox, () ->
    checked = $(this).is ':checked'
    if typeof(options) != 'undefined' && options.reverse
      checked = !checked
    if checked
      $(selector).slideDown()
    else $(selector).slideUp()

determineShouldProvideReasonNotUpToCurb = () ->
  motion = $('#report_motion_of_bus').val()
  upToCurb = $('#report_bus_up_to_curb').is ':checked'
  formSection = $('.reason-not-up-to-curb-info')
  if motion == 'Stopped' && !upToCurb
    formSection.slideDown()
  else formSection.slideUp()

$(document).ready ->
  $('form').showIfChecked '#report_motor_vehicle_collision',
                          '.motor-vehicle-collision-info'

  $('form').showIfChecked '#report_police_on_scene',
                          '.police-info'

  $('form').showIfChecked '#report_other_vehicle_owned_by_other_driver',
                          '.other-vehicle-owner-info', reverse: true

  $('form').showIfChecked '#report_passenger_incident',
                          '.passenger-incident-info'

  $('form').showIfChecked '#report_passenger_injured',
                          '.injured-passenger-info'

  $('form').on 'change', '#report_motion_of_bus',
               determineShouldProvideReasonNotUpToCurb

  $('form').on 'click', '#report_bus_up_to_curb',
               determineShouldProvideReasonNotUpToCurb
