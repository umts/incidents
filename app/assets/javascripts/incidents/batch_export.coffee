alreadyExportedWarning = (count) ->
  words = if count == 1
    ['incident has', 'this incident']
  else ['incidents have', 'these incidents']
  """
  #{count} selected #{words[0]} already been exported to Hastus.
  Please confirm that you would like to re-export #{words[1]}.
  """

handleExporting = ->
  inSelectMode = $('table.incidents th.batch-hastus-export').is ':visible'
  if inSelectMode
    ids = $('.batch-hastus-export input:checked').map ->
      $(this).data 'id'
    .toArray()
    alreadyExported= $('.batch-hastus-export input:checked').filter ->
      $(this).data 'exported_to_hastus'
    .length
    if alreadyExported > 0
      unless confirm alreadyExportedWarning(alreadyExported)
        return false
    format = $(this)[0].id
    window.location.href = 'incidents/batch_hastus_export?' + $.param(ids: ids) + '&' + $.param(format: format)

enableSelectMode = ->
  $('table.incidents .batch-hastus-export').show()
  $('.batch-hastus-export #xml-button').prop 'disabled', true
  $('.batch-hastus-export #csv-button').prop 'disabled', true
  $('.batch-hastus-export #main-button').hide()
  $('.batch-hastus-export #xml-button').show()
  $('.batch-hastus-export #csv-button').show()
  $('.batch-hastus-export #select-all').show()
  setSelectAllText()

handleIncidentSelected = ->
  selectedIncidentCount = $('.batch-hastus-export input:checked').length
  if selectedIncidentCount > 0
    $('.batch-hastus-export #xml-button').prop 'disabled', false
    $('.batch-hastus-export #csv-button').prop 'disabled', false
    $('.batch-hastus-export #xml-button').text "Generate XML export (#{selectedIncidentCount} selected)"
    $('.batch-hastus-export #csv-button').text "Generate CSV export (#{selectedIncidentCount} selected)"
  else
    $('.batch-hastus-export #xml-button').prop 'disabled', true
    $('.batch-hastus-export #csv-button').prop 'disabled', true
    $('.batch-hastus-export #xml-button').text 'Select incidents to export...'
    $('.batch-hastus-export #csv-button').text 'Select incidents to export...'

selectAllIncidents = ->
  if $(this).text() == 'Deselect all'
    $('.batch-hastus-export input:visible').prop('checked', false).trigger('change')
  else $('.batch-hastus-export input:visible').prop('checked', true).trigger('change')
  setSelectAllText()

setSelectAllText = ->
  incidentCount = $('.batch-hastus-export input:visible').length
  # if any are unchecked
  if $('.batch-hastus-export input:checked').length < incidentCount
    $('.batch-hastus-export #select-all').text "Select all (#{incidentCount})"
  else $('.batch-hastus-export #select-all').text 'Deselect all'

$(document).on 'turbolinks:load', ->
  $('.batch-hastus-export #main-button').on('click', enableSelectMode)
  $('.batch-hastus-export #xml-button').on('click', handleExporting)
  $('.batch-hastus-export #csv-button').on('click', handleExporting)
  $('.batch-hastus-export input').on('change', handleIncidentSelected)
  $('.batch-hastus-export #select-all').on('click', selectAllIncidents)
