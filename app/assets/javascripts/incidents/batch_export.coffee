alreadyExportedWarning = (count) ->
  words = if count == 1
    ['incident has', 'this incident']
  else ['incidents have', 'these incidents']
  """
  #{count} selected #{words[0]} already been exported.
  Please confirm that you would like to re-export #{words[1]}.
  """

handleExporting = ->
  inSelectMode = $('table.incidents th.batch-export').is ':visible'
  if inSelectMode
    ids = $('.batch-export input:checked').map ->
      $(this).data 'id'
    .toArray()
    alreadyExported= $('.batch-export input:checked').filter ->
      $(this).data 'exported'
    .length
    if alreadyExported > 0
      unless confirm alreadyExportedWarning(alreadyExported)
        return false
     window.location.href = 'incidents/batch_export?' + $.param(ids: ids)
  else
    $('table.incidents .batch-export').show()
    $(this).text 'Select incidents to export...'
    $('.batch-export #select-all').show()
    setSelectAllText()

handleIncidentSelected = ->
  selectedIncidentCount = $('.batch-export input:checked').length
  if selectedIncidentCount > 0
    $('.batch-export #main-button').text "Generate XML export (#{selectedIncidentCount} selected)"
  else $('.batch-export #main-button').text 'Select incidents to export...'

selectAllIncidents = ->
  if $(this).text() == 'Deselect all'
    $('.batch-export input:visible').prop('checked', false).change()
  else $('.batch-export input:visible').prop('checked', true).change()
  setSelectAllText()

setSelectAllText = ->
  incidentCount = $('.batch-export input:visible').length
  # if any are unchecked
  if $('.batch-export input:checked').length < incidentCount
    $('.batch-export #select-all').text "Select all (#{incidentCount})"
  else $('.batch-export #select-all').text 'Deselect all'

$(document).on 'turbolinks:load', ->
  $('.batch-export #main-button').click handleExporting
  $('.batch-export input').change handleIncidentSelected
  $('.batch-export #select-all').click selectAllIncidents
