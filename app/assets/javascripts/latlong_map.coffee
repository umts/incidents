marker = null

# fallback to PVTA if we can't geocode the incident's location
PVTA = { lat: 42.105552, lng: -72.596511 }

createMap = (mapSelector, latLng, newValues) ->
  map = new google.maps.Map mapSelector[0], { zoom: 15, tilt: 0, center: latLng }
  placeMarker map, latLng, newValues
  google.maps.event.addListener map, 'click', (event) ->
    latLong = { lat: event.latLng.lat(), lng: event.latLng.lng() }
    placeMarker map, latLong, true


fillLatLngFields = (latLng) ->
  $('#incident_latitude').val Number(latLng.lat.toFixed(5))
  $('#incident_longitude').val Number(latLng.lng.toFixed(5))

initLatLngMap = (mapSelector) ->
  if mapSelector[0].dataset.lat
    lat = parseFloat mapSelector.data('lat')
    lng = parseFloat mapSelector.data('lng')
    createMap mapSelector, { lat: lat, lng: lng }, false
  else
    location = mapSelector.data 'location'
    geocoder = new google.maps.Geocoder()
    geocoder.geocode address: location, (results, status) ->
      if status == google.maps.GeocoderStatus.OK
        result = results[0]
        createMap mapSelector, result.geometry.location, false
      else
        $('.no-geocode-alert').slideDown()
        createMap mapSelector, PVTA, false

placeMarker = (map, latLng, newValues) ->
  unless marker == null
    marker.setMap null
  marker = new google.maps.Marker position: latLng, map: map
  fillLatLngFields latLng
  if newValues
    reverseGeocode latLng

reverseGeocode = (latLng) ->
  geocoder = new google.maps.Geocoder()
  geocoder.geocode location: latLng, (results, status) ->
    address = results[0].address_components
    [street, zip, town, state] = ["", undefined, undefined, undefined]
    address.forEach (part) ->
      if part.types.includes("street_number")
        street += part.short_name + " "
      if part.types.includes("route")
        street += part.short_name
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
  $('#incident_report_town').val String(town)
  $('#incident_report_state').val String(state)
  $('#incident_report_zip').val String(zip)

$(document).on 'turbolinks:load', ->
  if $('.map').length > 0
    initLatLngMap $('.map')
