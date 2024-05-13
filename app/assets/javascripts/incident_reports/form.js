$(document).on('turbolinks:load', () => {
  let initialLatLng = [parseFloat($('#incident_latitude').val()), parseFloat($('#incident_longitude').val())];
  if (isNaN(initialLatLng[0]) || isNaN(initialLatLng[1])) {
    initialLatLng = [42.105552, -72.596511];
  }

  const map = L.map('latlong-selector').setView(initialLatLng, 13);
  const tileLayer = L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png');
  const marker = L.marker(initialLatLng, {draggable: true});

  const updateFields = () => {
    const latLong = marker.getLatLng();
    $('#incident_latitude').val(latLong.lat.toFixed(5));
    $('#incident_longitude').val(latLong.lng.toFixed(5));

    $.ajax({
      url: 'https://nominatim.openstreetmap.org/reverse',
      method: 'GET',
      headers: {'User-Agent': 'PVTAIncidents/1.0'}, // play nice and identify ourselves
      data: {format: 'json', lat: latLong.lat, lon: latLong.lng},
      success: (data) => {
        const location = [data.address['house_number'], data.address['road']].filter((x) => !!(x)).join(' ');
        $('#incident_report_location').val(location);
        $('#incident_report_town').val(data.address['city']);
        $('#incident_report_state').val(data.address['state']);
        $('#incident_report_zip').val(data.address['postcode']);
      },
    });
  };

  map.on('click', (e) => {
    marker.setLatLng(e.latlng);
    updateFields();
  });

  marker.on('moveend', () => {
    updateFields();
  });

  tileLayer.addTo(map);
  marker.addTo(map);
});
