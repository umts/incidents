marker = null

fillLatLngFields = (latLng) ->
  $('#incident_latitude').val latLng.lat()
  $('#incident_longitude').val latLng.lng()

initLatLngMap = ->
  pvta = { lat: 42.105552, lng: -72.596511 }
  map = new google.maps.Map $('.map')[0], { zoom: 15, center: pvta }

  google.maps.event.addListener map, 'click', (event) ->
    placeMarker map, event.latLng
    fillLatLngFields event.latLng

placeMarker = (map, latLng) ->
  unless marker == null
    marker.setMap null
  marker = new google.maps.Marker position: latLng, map: map

$(document).on 'turbolinks:load', ->
  if $('.map').length > 0
    initLatLngMap() 
