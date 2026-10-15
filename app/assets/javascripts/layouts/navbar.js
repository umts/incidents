addEventListener('turbolinks:load', () => {
  const newIncidentForm = document.getElementById('new-incident-navbar-form')

  if (newIncidentForm) {
    newIncidentForm.addEventListener('submit', (e) => {
      e.target.querySelector('button').disabled = true;
    });
  }
});
