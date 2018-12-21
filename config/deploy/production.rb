config = Net::SSH::Config.for 'incidents.pvta.com'
remote_user = config[:user] || ENV['USER']
port = config[:port] || ENV['PORT']
server 'incidents.pvta.com', user: remote_user, roles: %w(app db web), port: port
set :tmp_dir, "/tmp/#{remote_user}"
set :default_env, { 'PASSENGER_INSTANCE_REGISTRY_DIR' => '/home/umass/passenger_temp' }
