marker = null

# fallback to PVTA if we can't geocode the incident's location
PVTA = { lat: 42.105552, lng: -72.596511 }

createMap = (mapSelector, latLng, newValues) ->
  map = new google.maps.Map mapSelector[0], { zoom: 15, tilt: 0, center: latLng }
  if newValues
    placeMarker map, latLng, mapSelector, true
  else
    placeMarker map, latLng, mapSelector, false
  google.maps.event.addListener map, 'click', (event) ->
    latLong = { lat: event.latLng.lat(), lng: event.latLng.lng() }
    placeMarker map, latLong, mapSelector, true
    fillLatLngFields latLong

fillLatLngFields = (latLng) ->
  $('#incident_latitude').val Number(latLng.lat.toFixed(5))
  $('#incident_longitude').val Number(latLng.lng.toFixed(5))

initLatLngMap = (mapSelector) ->
  if mapSelector.attr 'lat'
    lat = parseFloat mapSelector.attr('lat')
    lng = parseFloat mapSelector.attr('lng')
    createMap mapSelector, { lat: lat, lng: lng }, false
  else
    createMap mapSelector, PVTA, true

placeMarker = (map, latLng, mapSelector, newValues) ->
  unless marker == null
    marker.setMap null
  marker = new google.maps.Marker position: latLng, map: map
  if newValues
    reverseGeocode latLng, mapSelector

reverseGeocode = (latLng, mapSelector) ->
  api_key = mapSelector.attr('api')
  url  = "https://maps.googleapis.com/maps/api/geocode/json?latlng=#{latLng.lat},#{latLng.lng}&key=#{api_key}"
  fetch(url).then (response) ->
    response.json().then (location) ->
      address = location.results[0].address_components
      [street, zip, town, state] = [undefined, undefined, undefined, undefined]
      address.forEach (part) ->
        if part.types.includes("route")
          street = part.short_name
        if part.types.includes("postal_code")
          zip = part.long_name
        if part.types.includes("locality")
          town = part.long_name
        if part.types.includes("administrative_area_level_1")
          state = part.long_name
      fillLocationFields street, zip, town, state
    .catch (error) ->
      $('.no-geocode-alert').slideDown()

fillLocationFields = (street, zip, town, state) ->
  $('#incident_report_location').val String(street)
  $('#incident_report_zip').val String(zip)
  $('#incident_report_town').val String(town)
  $('#incident_report_state').val String(state)

$(document).on 'turbolinks:load', ->
  if $('.map').length > 0
    initLatLngMap $('.map')
