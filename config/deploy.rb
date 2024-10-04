# frozen_string_literal: true

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
       'node_modules',
       'tmp/pids',
       'tmp/cache',
       'tmp/sockets',
       'vendor/bundle',
       '.bundle'

set :bundle_bins, fetch(:bundle_bins, []).push('bootsnap')

set :sidekiq_user, 'root'
set :sidekiq_service_unit_user, :system

before 'deploy:updated', 'bootsnap:precompile'
