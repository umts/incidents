# frozen_string_literal: true

server 'incidents.pvta.com',
       roles: %w[app db web worker],
       ssh_options: { forward_agent: false }

set :sidekiq_service_unit_name, 'sidekiq'
set :passenger_restart_with_touch, true
