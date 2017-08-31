remote_user = Net::SSH::Config.for('50.198.83.200')[:user] || ENV['USER']
server '50.198.83.200', user: remote_user
set :tmp_dir, "/tmp/#{remote_user}"
