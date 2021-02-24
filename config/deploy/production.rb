server 'incidents.pvta.com',
  roles: %w[app db web],
  ssh_options: { forward_agent: false }

set :passenger_restart_with_touch, true
