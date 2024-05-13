const pvtaLatLong = [42.105552, -72.596511]

$(document).on('turbolinks:load', () => {
  const map = L.map('latlong-selector').setView(pvtaLatLong, 13);
  L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png').addTo(map);
  L.marker(pvtaLatLong).addTo(map);
});
