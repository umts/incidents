marker = null

# fallback to PVTA if we can't geocode the incident's location
PVTA = { lat: 42.105552, lng: -72.596511 }

createMap = (latLng, placeInitialMarker) ->
  map = new google.maps.Map $('.map')[0], { zoom: 15, center: latLng }
  if placeInitialMarker
    placeMarker map, latLng
  google.maps.event.addListener map, 'click', (event) ->
    placeMarker map, event.latLng
    fillLatLngFields event.latLng

fillLatLngFields = (latLng) ->
  $('#incident_latitude').val latLng.lat()
  $('#incident_longitude').val latLng.lng()

initLatLngMap = ->
  if $('.map').data 'lat'
    createMap $('.map').data(), true
  else
    location = $('.map').data 'location'
    geocoder = new google.maps.Geocoder()
    geocoder.geocode address: location, (results) ->
      if results.length > 0
        result = results[0]
        createMap result.geometry.location
      else
        $('.no-geocode-alert').slideDown()
        createMap PVTA

placeMarker = (map, latLng) ->
  unless marker == null
    marker.setMap null
  marker = new google.maps.Marker position: latLng, map: map

$(document).on 'turbolinks:load', ->
  if $('.map')
    initLatLngMap() 
