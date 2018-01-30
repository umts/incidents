alreadyExportedWarning = -> (count)
  words = []
  if count == 1
    words.push 'incident has', 'this incident' 
  else words.push 'incidents have', 'these incidents'
  """
  #{count} selected #{words[0]} already been exported.
  Please doublecheck that you would like to re-export #{words[1]}.
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

handleIncidentSelected = ->
  selectedIncidentCount = $('.batch-export input:checked').length
  if selectedIncidentCount > 0
    $('.batch-export button').text "Generate XML export (#{selectedIncidentCount} selected)"
  else $('.batch-export button').text 'Select incidents to export...'

$(document).on 'turbolinks:load', ->
  $('.batch-export button').click handleExporting
  $('.batch-export input').change handleIncidentSelected
