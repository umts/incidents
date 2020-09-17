lock '~> 3.14'

set :application, 'incidents'
set :repo_url, 'git@github.com:umts/incidents.git'
set :branch, :master
set :keep_releases, 5
set :deploy_to, "/srv/#{fetch :application}"

append :linked_files,
       'config/database.yml',
       'config/secrets.yml'

append :linked_dirs,
       'claims_xml',
       'log',
       'tmp/pids',
       'tmp/cache',
       'tmp/sockets',
       'vendor/bundle',
       '.bundle'
