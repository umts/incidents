handleExporting = ->
  inSelectMode = $('table.incidents th.batch-export').is ':visible'
  if inSelectMode
    ids = $('.batch-export input:checked').map ->
      $(this).data 'id'
    .toArray()
    alreadyExported= $('.batch-export input:checked').filter ->
      $(this).data 'exported'
    if alreadyExported.length > 0
      if alreadyExported.length == 1
        warning = '1 selected incident has already been exported.'
      else warning = "#{alreadyExported.length} selected incidents have already been exported."
      warning += "\nPlease doublecheck that you would like to re-export this incident."
      unless confirm warning
        return false
     window.location.href = 'incidents/batch_export?' + $.param(ids: ids)
  else
    $('table.incidents .batch-export').show()
    $(this).text 'Select incidents to export...'

handleIncidentSelected = ->
  selectedIncidentCount = $('.batch-export input:checked').length
  if selectedIncidentCount > 0
    $('.batch-export button').text "Generate XML export (#{selectedIncidentCount} selected)"
  else $('.batch-export button').text 'Select incidents to export...'

$(document).on 'turbolinks:load', ->
  $('.batch-export button').click handleExporting
  $('.batch-export input').change handleIncidentSelected
