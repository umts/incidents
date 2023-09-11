# frozen_string_literal: true

lock '~> 3.14'

set :application, 'incidents'
set :repo_url, 'https://github.com/umts/incidents.git'
set :branch, :main
set :keep_releases, 5
set :deploy_to, "/srv/#{fetch :application}"

append :linked_files,
       'config/database.yml',
       'config/sidekiq.yml',
       'config/credentials/production.key'

append :linked_dirs,
       'claims_xml',
       'log',
       'tmp/pids',
       'tmp/cache',
       'tmp/sockets',
       'vendor/bundle',
       '.bundle'

set :sidekiq_user, 'root'
set :sidekiq_service_unit_user, :system
