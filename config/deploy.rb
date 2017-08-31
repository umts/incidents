lock '3.9.0'

set :application, 'incidents'
set :repo_url, 'git@github.com:umts/incidents.git'
set :scm, :git
set :branch, :master
set :keep_releases, 5
set :deploy_to, "/srv/#{fetch :application}"
set :log_level

set :linked_files, fetch(:linked_files, []).push(
  'config/database.yml',
  'config/application.yml'
)

set :linked_dirs, fetch(:linked_dirs, []).push(
  'log'
)
