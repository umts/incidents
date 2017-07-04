filterDivisions = () ->
  $(this).siblings('button').removeClass 'btn-primary'
  $(this).addClass 'btn-primary'
  division = $(this).text()
  $('table.incidents tbody tr').show()
  if division != 'All'
    $('table.incidents tbody tr').filter () ->
      $(this).data('division') != division
    .hide()

$(document).ready ->
  $('.division-filter').on 'click', 'button', filterDivisions
