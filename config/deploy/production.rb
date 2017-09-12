remote_user = Net::SSH::Config.for('50.198.83.200')[:user] || ENV['USER']
server '50.198.83.200', user: remote_user, roles: %w(app db web), port: 2250
set :tmp_dir, "/tmp/#{remote_user}"
set :default_env, { 'PASSENGER_INSTANCE_REGISTRY_DIR' => '/home/umass/passenger_temp' }
