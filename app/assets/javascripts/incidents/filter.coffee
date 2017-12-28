$.fn.filterTableFromButton = (tableClass, dataAttribute) ->
  $(this).siblings('button').removeClass 'btn-primary'
  $(this).addClass 'btn-primary'
  filterGroup = $(this).text()
  tableRows = $("table.#{tableClass} tbody tr").show()
  if filterGroup != 'All'
    tableRows.filter () ->
      $(this).data(dataAttribute) != filterGroup
    .hide()

$(document).on 'turbolinks:load', ->
  $('.filters.divisions').on 'click', 'button', () ->
    $(this).filterTableFromButton 'incidents', 'division'
  $('.filters.groups').on 'click', 'button', () ->
    $(this).filterTableFromButton 'index', 'group'
