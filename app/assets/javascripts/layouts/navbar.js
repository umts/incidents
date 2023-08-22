addEventListener('turbolinks:load', () => {
  document.getElementById('new-incident-navbar-form').addEventListener('submit', (e) => {
    e.target.querySelector('button').disabled = true;
  });
});
